defmodule Moongate.PoolMutation do
  defstruct(
    by: 0,
    mode: "linear",
    time_started: nil
  )
end

defmodule Moongate.PoolState do
  defstruct(
    attributes: %{},
    cascades: [],
    index: 0,
    members: [],
    name: nil,
    publish_to: [],
    spec: nil,
    stage: nil,
    touches: [],
    touch_state: []
  )
end

defmodule Moongate.Pools.Pool do
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Processes

  def start_link({name, stage, pool}) do
    state = %Moongate.PoolState{
      attributes: get_attributes(pool),
      cascades: get_cascades(pool),
      name: name,
      spec: pool,
      stage: stage,
      touches: get_touches(pool)
    }
    link(state, "pool", name)
  end

  def handle_cast({:init}, state) do
    Enum.map(state.cascades, &initialize_cascade/1)
    Enum.map(state.touches, &(initialize_touch(&1, state)))
    {:noreply, state}
  end

  @doc """
    Add a new member to the pool, merging default attributes with those
    provided.
  """
  def handle_cast({:add_to_pool, event, params}, state) do
    attributes = Enum.map(state.attributes, &(initial_attributes_for_member(&1, params)))
    state = %{state | members: state.members ++ [new_pool_member(attributes, state)]}
    stage_name = Atom.to_string(state.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:bubble, event, state.spec, :create})
    modified = %{state | index: state.index + 1}
    publish_to(modified)
    {:noreply, modified}
  end

  def handle_cast({:remove_from_pool, event, target}, state) do
    member = Enum.find(state.members, &(&1[:origin] == target[:origin]))
    members = List.delete(state.members, member)
    stage_name = Atom.to_string(state.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:bubble, %{event | params: {target}}, state.spec, :drop})
    modified = %{state | members: members}
    publish_to(modified)
    {:noreply, modified}
  end

  def handle_cast({:bubble, event, from, key}, state) do
    cascaded = state.cascades |> Enum.map(fn(cascade) ->
      if elem(cascade, 1) == {:upon, from, key} do
        Enum.map(state.members, &(pool_callback(elem(cascade, 0), &1, state, event.params)))
      end
    end)
    {:noreply, state}
  end

  @doc """
    Asynchronously call a function defined on the pool module.
  """
  def handle_cast({:cause, callback, member}, state) do
    pool_callback(callback, member, state, nil)
    {:noreply, state}
  end
  def handle_cast({:cause, callback, member, params}, state) do
    pool_callback(callback, member, state, params)
    {:noreply, state}
  end

  @doc """
    Send a packet to a Moongate.SocketOrigin describing the shape of
    members of this pool.
  """
  def handle_cast({:describe, origin}, state) do
    attributes = Enum.map(state.attributes, fn(attribute) ->
      case attribute do
        {key, {type, value}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type) <> "¦"
        {key, {type}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type) <> "¦"
      end
    end)
    write_to(origin, :describe, List.to_string(attributes))
    {:noreply, state}
  end

  def handle_cast({:publish_to, pid, tag}, state) do
    {:noreply, %{state | publish_to: state.publish_to ++ [{pid, tag}]}}
  end

  @doc """
    Handle a pool member mutation event.
  """
  def handle_cast({:mutate, target, attribute, delta, params}, state) do
    member = Enum.find(state.members, &(&1[:__moongate_pool_index] == target[:__moongate_pool_index]))
    members = List.delete(state.members, member)
    modified = %{state | members: members ++ [mutate(member, attribute, delta, params)]}
    publish_to(modified)
    {:noreply, modified}
  end

  def handle_cast({:set, target, attribute, value}, state) do
    member = Enum.find(state.members, &(&1[:__moongate_pool_index] == target[:__moongate_pool_index]))
    members = List.delete(state.members, member)
    modified_member = set(member, attribute, value)
    modified = %{state | members: members ++ [modified_member]}
    {:noreply, modified}
  end

  def handle_cast({:touch_state, results}, state) do
    results |> Enum.map(fn(result) ->
      case result do
        {this, touching} ->
          touching |> Enum.map(fn(that) ->
            pool_callback(:touches, this, state, {that[:__moongate_pool], that})
          end)
      end
    end)
    {:noreply, state}
  end

  @doc """
    Synchronously return all members of the pool that match
    the provided params.
  """
  def handle_call({:get, params}, _from, state) do
    members = Enum.filter(state.members, fn(member) ->
      Enum.all?(params, fn({key, value}) ->
        elem(member[key], 0) == value
      end)
    end)
    publish_to(state)
    {:reply, members, state}
  end

  @doc """
    Synchronously call a function defined on the pool module,
    replying with the result.
  """
  def handle_call({:cause, callback, member, params}, _from, state) do
    result = pool_callback(callback, member, state, params)
    {:reply, result, state}
  end

  @doc """
    Given a callback and a number of milliseconds, cascade that
    callback as it is defined on the pool module on a timer
    set to the interval provided.
  """
  def handle_info({:cascade, callback, {:every, time}}, state) do
    Enum.map(state.members, &(pool_callback(callback, &1, state)))
    Process.send_after(self(), {:cascade, callback, {:every, time}}, time)
    {:noreply, state}
  end

  # Return the default value given the type of a default member
  # attribute.
  defp default_value_for_type(type) do
    case type do
      :int -> 0
      :string -> ""
      :origin -> %Moongate.SocketOrigin{}
    end
  end

  # Get the member attributes as they are defined on the pool
  # module.
  defp get_attributes(module_name) do
    world = String.to_atom(String.capitalize(world_name))
    pool_module = Module.safe_concat([world, Pools, module_name])
    attributes = apply(pool_module, :__moongate__pool_attributes, [])
    attributes
  end

  # Get the cascades as they are defined on the pool module.
  defp get_cascades(module_name) do
    world = String.to_atom(String.capitalize(world_name))
    pool_module = Module.safe_concat([world, Pools, module_name])
    cascades = apply(pool_module, :__moongate__pool_cascades, [])
    cascades
  end

  # Get the cascades as they are defined on the pool module.
  defp get_touches(module_name) do
    world = String.to_atom(String.capitalize(world_name))
    pool_module = Module.safe_concat([world, Pools, module_name])
    touches = apply(pool_module, :__moongate__pool_touches, [])
    touches
  end

  # Return an initial attribute for a member when a default is
  # not provided, determining the default from the type.
  defp initial_attributes_for_member({key, {type}}, params) do
    initial_attributes_for_member({key, {type, default_value_for_type(type)}}, params)
  end

  # Return an initial attribute for a member with any params
  # passed to the construction of the member taking prescendence.
  defp initial_attributes_for_member({key, {type, initial_value}}, params) do
    {key, {params[key] || initial_value, []}}
  end

  # Initialize a cascade defined on the pool module.
  defp initialize_cascade({cascade, condition}) do
    case condition do
      {:every, time} -> Process.send_after(self(), {:cascade, cascade, condition}, time)
      _ -> nil
    end
  end

  defp initialize_touch({pool, :box, keys}, state) do
    recursive = %Moongate.RecursiveSwitch{
      arguments: {:box, [], [], keys},
      callback: &touch_test/1,
      response: {self, :touch_state}
    }
    {:ok, pid} = spawn_new(:recursive, {recursive, "#{UUID.uuid4(:hex)}"})
    tell_async(:stage, state.stage, {:pool_publish, state.spec, pid, :this})
    tell_async(:stage, state.stage, {:pool_publish, pool, pid, :that})
  end

  # Return a mutated pool member.
  defp mutate(member, attribute, delta, params) do
    {value, mutations} = member[attribute]
    mutation = mutation_from(delta, params)

    if Enum.any?(mutations, &(Map.get(&1, :member) == params[:member])) do
      old_mutation = hd(Enum.filter(mutations, &(Map.get(&1, :member) == params[:member])))
      mutations = List.delete(mutations, old_mutation)
      Keyword.put(member, attribute, {value + mutation_delta(old_mutation), mutations ++ [mutation]})
    else
      Keyword.put(member, attribute, {value, mutations ++ [mutation]})
    end
  end

  defp mutation_delta(mutation) do
    time_passed = Moongate.Time.current_ms - mutation.time_started
    mutation.by * time_passed
  end

  defp mutation_from(delta, params) do
    %Moongate.PoolMutation{
      by: delta,
      mode: params[:mode],
      time_started: Moongate.Time.current_ms
    }
  end

  defp new_pool_member(attributes, state) do
    [__moongate_pool_index: state.index,
     __moongate_pool_name: state.name,
     __moongate_pool: state.spec
    ] ++ attributes
  end

  # Call a function defined on the pool module with a member of
  # the pool designated as a target. That member, along with
  # a list of all members and any provided params will be
  # passed to the callback function.
  defp pool_callback(callback, member, state), do: pool_callback(callback, member, state, nil)
  defp pool_callback(callback, member, state, params) do
    world = String.to_atom(String.capitalize(world_name))
    pool_module = Module.safe_concat([world, Pools, state.spec])
    pools = Map.put(%{}, state.spec, state.members)
    event = %{
      this: member,
      params: params,
      pools: pools,
      stage: state.stage
    }
    if params do
      apply(pool_module, callback, [event, params])
    else
      apply(pool_module, callback, [event])
    end
  end

  defp publish_to(state) do
    state.publish_to |> Enum.map(fn({pid, tag}) ->
      tell_pid_async(pid, {:publish, state.members, tag})
    end)
  end

  defp set(member, attribute, new_value) do
    {old_value, mutations} = member[attribute]
    Keyword.put(member, attribute, {new_value, mutations})
  end

  def touch_test({:box, these, those, {x, y, height, width}}) do
    touching = these |> Enum.map(fn(this) ->
      matches = Enum.filter(those, fn(that) ->
        this_x = Moongate.Data.pool_member_attr(this, x)
        this_y = Moongate.Data.pool_member_attr(this, y)
        that_x = Moongate.Data.pool_member_attr(that, x)
        that_y = Moongate.Data.pool_member_attr(that, y)
        this_height = Moongate.Data.pool_member_attr(this, height)
        this_width = Moongate.Data.pool_member_attr(this, width)
        that_height = Moongate.Data.pool_member_attr(that, height)
        that_width = Moongate.Data.pool_member_attr(that, width)

        this[:__moongate_pool_index] != that[:__moongate_pool_index] &&
          this_x < that_x + that_width &&
          this_x + this_width > that_x &&
          this_y < that_y + that_height &&
          this_y + this_height > that_y
      end)
      {this, matches}
    end)
  end
end
