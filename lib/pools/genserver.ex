defmodule Moongate.Pool.GenServer do
  import Moongate.Macros.SocketWriter
  import Moongate.Pool.Mutations
  use GenServer
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Mutations, genserver: true
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
    member = new_pool_member(attributes, state)

    state
    |> Map.put(:members, state.members ++ [member])
    |> Map.put(:index, state.index + 1)
    |> member_update(member, :create)
    |> no_reply
  end

  @doc """
    Remove a member from the pool as well as any associated
    subscribers.
  """
  def handle_cast({:remove_from_pool, origin}, state) do
    member = state.members
    |> Enum.filter(&(elem(&1[:origin], 0).id == origin.id))
    |> List.first

    state
    |> Map.put(:members, Enum.filter(state.members, &(&1 != member)))
    |> Map.put(:subscribers, Enum.filter(state.subscribers, &(&1.id != origin.id)))
    |> member_removed(member[:__moongate_pool_index])
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
    updated = event.origin
    |> find_owned_member(state)
    |> deed_callback(event, state)
    |> replace_member(state)
    |> no_reply
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
    |> notify_subscribed(event.origin)
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

  defp cast_params(params) do
    params
    |> Tuple.to_list
    |> Enum.map(fn(param) ->
      cond do
        String.match?(param, ~r/[0-9]+/) -> String.to_integer(param)
        true -> param
      end
    end)
    |> List.to_tuple
  end

  defp deed_callback(member, event, state) do
    if member != nil && event.use_deed != nil && deed_valid?(event.use_deed, state) do
      if deed_has_function(event.use_deed, event.cast) do
        event.use_deed
        |> Moongate.Deed.Service.deed_module
        |> apply(String.to_atom(event.cast), [member, cast_params(event.params)])
        |> notify_partial(state)
        |> mutations(member)
      else
        member
      end
    else
      member
    end
  end

  defp deed_has_function(deed, func_name) do
    deed
    |> Moongate.Deed.Service.deed_module
    |> Moongate.Modules.has_function?(func_name)
  end

  defp deed_valid?(deed, state) do
    Moongate.Pool.Service.get_deeds(state.spec)
    |> Enum.any?(&(Moongate.Atoms.to_strings(&1) == deed))
  end

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
    attributes
    |> Enum.into(%{
      __moongate_mutations: [],
      __moongate_pool_index: state.index,
      __moongate_pool_name: state.name,
      __moongate_pool: state.spec
    })
  end

  defp notify_subscribed(state, origin) do
    write_to(origin, :subscribe, "pool", "#{state.name} #{pool_attributes_string(state)}")

    for member <- state.members do
      member_update(state, member, :refresh, origin)
    end

    state
  end

  defp notify_partial(member, state) do
    
    for mutation <- member.__moongate_mutations do
      case mutation do
        {:transform, type, attribute, tag, amount} ->
          "#{state.name} #{member.__moongate_pool_index} #{type}:#{tag} #{attribute} #{amount}"
          |> write_to_all_subscribers(:transform, state)
        _ ->
          IO.puts "foo"
      end
    end
    member
  end

  defp member_removed(state, index) do
    write_to_all_subscribers("#{state.name} #{index}", :remove, state)
    state
  end

  defp member_update(state, member) do
    "#{state.name} #{member[:__moongate_pool_index]} "
    <> (member
        |> Moongate.Packets.whitelist(publishable(state))
        |> Moongate.Pool.Service.member_to_string)
  end

  defp member_update(state, member, action) do
    member_update(state, member)
    |> write_to_all_subscribers(action, state)
    state
  end

  defp member_update(state, member, action, origin) do
    write_to(origin, action, "pool", member_update(state, member))
  end

  defp pool_attributes_string(state) do
    Enum.map(state.attributes, fn(attribute) ->
      case attribute do
        {key, {type, _value}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type)
        {key, {type}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type)
      end
    end)
    |> Enum.join(" ")
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

  defp publishable(state) do
    state.spec
    |> Moongate.Pool.Service.pool_module
    |> apply(:__moongate__pool_publishes, [])
  end

  defp replace_member(member, state) do
    %{state | members:
      state.members
      |> Enum.filter(&(&1.__moongate_pool_index != member.__moongate_pool_index))
      |> List.insert_at(0, member)
     }
  end

  # Set one of a pool member's attributes to a new value.
  defp set(member, attribute, new_value) do
    {_old_value, transforms} = member[attribute]
    Keyword.put(member, attribute, {new_value, transforms})
  end

  defp write_to_all_subscribers(message, action, state) do
    write_to_all(state.subscribers, action, "pool", message)
  end
end
