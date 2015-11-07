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
    members: [],
    name: nil,
    spec: nil,
    stage: nil,
    conveys: []
  )
end

defmodule Moongate.Pools.Pool do
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Processes

  def start_link({name, stage, pool}) do
    attributes = get_attributes(pool)
    conveys = get_conveys(pool)
    state = %Moongate.PoolState{
      attributes: attributes,
      name: name,
      stage: stage,
      conveys: conveys,
      spec: pool
    }
    link(state, "pool", name)
  end

  def handle_cast({:init}, state) do
    Enum.map(state.conveys, &(initialize_convey(&1, state)))
    {:noreply, state}
  end

  @doc """
    Add a new member to the pool, merging default attributes with those
    provided.
  """
  def handle_cast({:add_to_pool, event, params}, state) do
    attributes = Enum.map(state.attributes, &(initial_attributes_for_member(&1, params)))
    state = %{state | members: state.members ++ [attributes]}
    stage_name = Atom.to_string(state.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:bubble, event, state.spec, :init})
    {:noreply, state}
  end

  def handle_cast({:bubble, event, from, key}, state) do
    conveyed = state.conveys |> Enum.map(fn(convey) ->
      if elem(convey, 1) == {:upon, from, key} do
        Enum.map(state.members, &(pool_callback(elem(convey, 0), &1, state)))
      end
    end)

    {:noreply, state}
  end

  @doc """
    Asynchronously call a function defined on the pool module.
  """
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
        {key, {type, value}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type) <> " "
        {key, {type}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type) <> " "
      end
    end)
    write_to(origin, :describe, List.to_string(attributes))
    {:noreply, state}
  end

  @doc """
    Handle a pool member mutation event.
  """
  def handle_cast({:mutate, target, attribute, delta, params}, state) do
    member = Enum.find(state.members, &(&1[:origin] == target[:origin]))
    members = List.delete(state.members, member)
    {:noreply, %{state | members: members ++ [mutate(member, attribute, delta, params)]}}
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
    Given a callback and a number of milliseconds, convey that
    callback as it is defined on the pool module on a timer
    set to the interval provided.
  """
  def handle_info({:convey, callback, {:every, time}}, state) do
    Enum.map(state.members, &(pool_callback(callback, &1, state)))
    Process.send_after(self(), {:convey, callback, {:every, time}}, time)
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

  # Get the conveys as they are defined on the pool module.
  defp get_conveys(module_name) do
    world = String.to_atom(String.capitalize(world_name))
    pool_module = Module.safe_concat([world, Pools, module_name])
    conveys = apply(pool_module, :__moongate__pool_conveys, [])
    conveys
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

  # Initialize a convey defined on the pool module.
  defp initialize_convey({convey, condition}, state) do
    case condition do
      {:every, time} -> Process.send_after(self(), {:convey, convey, condition}, time)
      _ -> nil
    end
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

  # Call a function defined on the pool module with a member of
  # the pool designated as a target. That member, along with
  # a list of all members and any provided params will be
  # passed to the callback function.
  defp pool_callback(callback, member, state), do: pool_callback(callback, member, state, [])
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
    apply(pool_module, callback, [event, params])
  end
end
