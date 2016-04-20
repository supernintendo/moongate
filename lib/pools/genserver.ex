defmodule Moongate.Pool.GenServer do
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Processes

  ### Public

  @doc """
    Start the pool process.
  """
  def start_link({name, stage, pool}) do
    state = %Moongate.Pool.GenServer.State{
      attributes: Moongate.Pool.Service.get_attributes(pool),
      name: name,
      spec: pool,
      stage: stage
    }
    link(state, "pool", name)
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    {:noreply, state}
  end

  @doc """
    Add a new member to the pool, merging default attributes
    with those provided.
  """
  def handle_cast({:add_to_pool, params}, state) do
    attributes = Enum.map(state.attributes, &(initial_attributes_for_member(&1, params)))

    state
    |> Map.put(:index, state.index + 1)
    |> Map.put(:members, state.members ++ [new_pool_member(attributes, state)])
    |> no_reply
  end

  @doc """
    Remove a member from the pool as well as any associated
    subscribers.
  """
  def handle_cast({:remove_from_pool, origin}, state) do
    state
    |> Map.put(:members, Enum.filter(state.members, &(elem(&1[:origin], 0).id != origin.id)))
    |> Map.put(:subscribers, Enum.filter(state.subscribers, &(&1.id != origin.id)))
    |> no_reply
  end

  @doc """
    Call a function within all deeds defined on this pool.
  """
  def handle_cast({:use_all_deeds, event}, state) do
    deeds = Enum.map(Moongate.Pool.Service.get_deeds(state.spec), fn deed ->
      Moongate.Atoms.to_strings(deed)
    end)
    Enum.map(deeds, &(tell_pid({:use_deed, %{event | use_deed: &1}}, self)))
    {:noreply, state}
  end

  @doc """
    Call a function within a deed defined on this pool.
  """
  def handle_cast({:use_deed, event}, state) do
    member = find_owned_member(event.origin, state)

    if member !=nil do
      if event.use_deed != nil do
        valid = Enum.any?(Moongate.Pool.Service.get_deeds(state.spec), fn deed ->
          Moongate.Atoms.to_strings(deed) == event.use_deed
        end)
        if valid do
          if (Moongate.Deed.Service.has_function?(Moongate.Deed.Service.deed_module(event.use_deed), event.cast)) do
            apply(Moongate.Deed.Service.deed_module(event.use_deed), String.to_atom(event.cast), [member, event.params, event])
          end
        end
      end
    end
    {:noreply, state}
  end

  @doc """
    Send a packet to an origin describing the shape of
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
    Handle a pool member transformation event.
  """
  def handle_cast({:transform, target, attribute, delta, params}, state) do
    member = Enum.find(state.members, &(&1[:__moongate_pool_index] == target[:__moongate_pool_index]))
    members = List.delete(state.members, member)
    modified = %{state | members: members ++ [transform(member, attribute, delta, params)]}
    {:noreply, modified}
  end

  @doc """
    Set an attribute of a pool member to a value.
  """
  def handle_cast({:set, target, attribute, value}, state) do
    member = Enum.find(state.members, &(&1[:__moongate_pool_index] == target[:__moongate_pool_index]))
    members = List.delete(state.members, member)
    modified_member = set(member, attribute, value)
    modified = %{state | members: members ++ [modified_member]}
    {:noreply, modified}
  end

  @doc """
    Add an origin to this pool's list of subscribers,
    effectively causing it to receiving all future
    packets related to changes and events within
    this pool.
  """
  def handle_cast({:subscribe, event}, state) do
    %{state | subscribers: state.subscribers ++ [event.origin]}
    |> no_reply
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

  ### Private

  # Return the default value given the type of a default member
  # attribute.
  defp default_value_for_type(type) do
    case type do
      :int -> 0
      :string -> ""
      :origin -> %Moongate.Origin{}
    end
  end

  # Find the member of this pool that corresponds to
  # an origin.
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

  # Return an initial attribute for a member when a
  # default is not provided, determining the default from
  # the type.
  defp initial_attributes_for_member({key, {type}}, params) do
    initial_attributes_for_member({key, {type, default_value_for_type(type)}}, params)
  end

  # Return an initial attribute for a member with any
  # params passed to the construction of the member
  # taking prescendence.
  defp initial_attributes_for_member({key, {_type, initial_value}}, params) do
    {key, {params[key] || initial_value, []}}
  end

  # Return a transformed pool member.
  defp transform(member, attribute, delta, params) do
    {value, transforms} = member[attribute]
    transform = transform_from(delta, params)

    if Enum.any?(transforms, &(Map.get(&1, :member) == params[:member])) do
      old_transform = hd(Enum.filter(transforms, &(Map.get(&1, :member) == params[:member])))
      transforms = List.delete(transforms, old_transform)
      Keyword.put(member, attribute, {value + transform_delta(old_transform), transforms ++ [transform]})
    else
      Keyword.put(member, attribute, {value, transforms ++ [transform]})
    end
  end

  # Get the current value that is being transformed
  # based on the time that has passed since the
  # transformation began.
  defp transform_delta(transform) do
    time_passed = Moongate.Time.current_ms - transform.time_started
    transform.by * time_passed
  end

  # Return a data structure which represents a
  # transformation of one of a pool member's attributes
  # over time.
  defp transform_from(delta, params) do
    %Moongate.PoolTransform{
      by: delta,
      mode: params[:mode],
      time_started: Moongate.Time.current_ms
    }
  end

  # Return attributes for a new pool member.
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

  # Set one of a pool member's attributes to a new value.
  defp set(member, attribute, new_value) do
    {_old_value, transforms} = member[attribute]
    Keyword.put(member, attribute, {new_value, transforms})
  end
end
