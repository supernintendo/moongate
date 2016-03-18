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
    index: 0,
    members: [],
    name: nil,
    spec: nil,
    stage: nil,
    subscribers: []
  )
end

defmodule Moongate.Pools.Pool do
  alias Moongate.Service.Deeds, as: Deeds
  alias Moongate.Service.Pools, as: Pools
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Processes

  def start_link({name, stage, pool}) do
    state = %Moongate.PoolState{
      attributes: Pools.get_attributes(pool),
      name: name,
      spec: pool,
      stage: stage
    }
    link(state, "pool", name)
  end

  def handle_cast({:init}, state) do
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
    GenServer.cast(stage, {:relay, event, state.spec, :create})
    modified = %{state | index: state.index + 1}
    {:noreply, modified}
  end

  def handle_cast({:remove_from_pool, event, target}, state) do
    member = Enum.find(state.members, &(&1[:origin] == target[:origin]))
    members = List.delete(state.members, member)
    stage_name = Atom.to_string(state.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:relay, %{event | params: {target}}, state.spec, :drop})
    modified = %{state | members: members}
    {:noreply, modified}
  end

  def handle_cast({:use_all_deeds, event}, state) do
    deeds = Enum.map(Pools.get_deeds(state.spec), fn deed ->
      Moongate.Atoms.to_strings(deed)
    end)
    Enum.map(deeds, &(tell_pid_async(self, {:use_deed, %{event | use_deed: &1}})))
    {:noreply, state}
  end

  def handle_cast({:use_deed, event}, state) do
    member = find_owned_member(event.origin, state)

    if member !=nil do
      if event.use_deed != nil do
        valid = Enum.any?(Pools.get_deeds(state.spec), fn deed ->
          Moongate.Atoms.to_strings(deed) == event.use_deed
        end)
        if valid do
          if (Deeds.has_function?(Deeds.deed_module(event.use_deed), event.cast)) do
            apply(Deeds.deed_module(event.use_deed), String.to_atom(event.cast), [member, event.params, event])
          end
        end
      end
    end
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
        {key, {type, _value}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type) <> "¦"
        {key, {type}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type) <> "¦"
      end
    end)
    write_to(origin, :describe, List.to_string(attributes))
    {:noreply, state}
  end

  @doc """
    Handle a pool member mutation event.
  """
  def handle_cast({:mutate, target, attribute, delta, params}, state) do
    member = Enum.find(state.members, &(&1[:__moongate_pool_index] == target[:__moongate_pool_index]))
    members = List.delete(state.members, member)
    modified = %{state | members: members ++ [mutate(member, attribute, delta, params)]}
    {:noreply, modified}
  end

  def handle_cast({:set, target, attribute, value}, state) do
    member = Enum.find(state.members, &(&1[:__moongate_pool_index] == target[:__moongate_pool_index]))
    members = List.delete(state.members, member)
    modified_member = set(member, attribute, value)
    modified = %{state | members: members ++ [modified_member]}
    {:noreply, modified}
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

  def handle_call({:subscribe, origin}, _from, state) do
    modified = %{state | subscribers: state.subscribers ++ [origin]}
    # Enum.map(state.members, &(publish_all(&1, origin)))
    {:reply, :ok, state}
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

  defp find_owned_member(origin, state) do
    results = Enum.filter(state.members, fn (member) ->
      {member_origin, _} = member[:origin]
      origin.id == member_origin.id
    end)
    if length(results) > 0 do
      hd(results)
    else
      nil
    end
  end

  # Return an initial attribute for a member when a default is
  # not provided, determining the default from the type.
  defp initial_attributes_for_member({key, {type}}, params) do
    initial_attributes_for_member({key, {type, default_value_for_type(type)}}, params)
  end

  # Return an initial attribute for a member with any params
  # passed to the construction of the member taking prescendence.
  defp initial_attributes_for_member({key, {_type, initial_value}}, params) do
    {key, {params[key] || initial_value, []}}
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

  defp set(member, attribute, new_value) do
    {_old_value, mutations} = member[attribute]
    Keyword.put(member, attribute, {new_value, mutations})
  end
end
