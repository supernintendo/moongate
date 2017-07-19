defmodule Moongate.Ring do
  use GenServer
  alias Moongate.{
    Core,
    CoreETS,
    CoreEvent,
    CoreNetwork,
    CoreTable,
    CoreTypes,
    CoreUtility,
    RingState,
    Zone
  }

  @factory Application.get_env(:moongate, :packet).factory

  def start_link(%RingState{} = state, _name) do
    GenServer.start_link(__MODULE__, state)
  end

  def handle_info(:init, %RingState{} = state) do
    zone_name = Zone.format_name({state.zone, state.zone_id})
    Core.log({:ring, "Ring {{#{zone_name}}, #{state.name}}"}, :up)

    {:noreply, init_ring(state)}
  end

  def handle_info({:trigger, handler_name, event}, %RingState{} = state) do
    trigger(state, handler_name, event)

    {:noreply, state}
  end

  def handle_call({:add_member, params}, _from, %RingState{} = state) do
    state =
      new_member(state, params)
      |> add_member(state)

    {:reply, {:ok, state.index}, %{state | index: state.index + 1}}
  end

  def handle_call({:establish, origin}, _from, %RingState{zone: zone, zone_id: zone_id, name: ring_name} = state) do
    @factory.show_morphs({zone, zone_id, ring_name}, state.morphs)
    |> CoreNetwork.send_packet(origin)

    if member_count(state) > 0 do
      @factory.index_members({zone, zone_id, ring_name}, {get_members(state), state.attributes})
      |> CoreNetwork.send_packet(origin)
    end

    {:reply, :ok, state}
  end

  def handle_call(:get_count, _from, %RingState{} = state) do
    {:reply, {:ok, member_count(state)}, state}
  end

  def handle_call({:get_member_indices, condition}, _from, %RingState{} = state) do
    results =
      get_members(state)
      |> Enum.filter(condition)
      |> Enum.map(&(&1[:__index__]))

    {:reply, {:ok, results}, state}
  end

  def handle_call(:get_state, _from, %RingState{} = state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call({:get_members, member_indices, %{} = _opts}, _from, %RingState{} = state) do
    members =
      member_indices
      |> Enum.map(&(get_member(&1, state)))

    {:reply, {:ok, members}, state}
  end

  def handle_call({:remove_members, condition}, _from, %RingState{} = state) when is_function(condition) do
    state =
      get_members(state)
      |> Enum.filter(condition)
      |> Enum.map(&(&1.__index__))
      |> remove_members(state)

    {:reply, :ok, state}
  end

  def handle_call({:remove_members, member_indices}, _from, %RingState{} = state) do
    state =
      member_indices
      |> remove_members(state)

    {:reply, :ok, state}
  end

  def handle_call({:set_on_members, member_indices, changes}, _from, %RingState{} = state) do
    state =
      state
      |> set_on_members(member_indices, changes)

    {:reply, :ok, state}
  end

  def handle_info({:set_on_members, member_indices, changes}, %RingState{} = state) do
    state =
      state
      |> set_on_members(member_indices, changes)

    {:noreply, state}
  end

  def handle_call({:morph_members, member_indices, rule, key, tween}, _from, %RingState{} = state) do
    state =
      state
      |> morph_members(member_indices, rule, key, tween)

    {:reply, :ok, state}
  end

  def handle_call({:cure_members, member_indices, rule, key}, _from, %RingState{} = state) do
    state =
      state
      |> cure_members(member_indices, rule, key)

    {:reply, :ok, state}
  end

  def get_attributes(module) do
    if CoreUtility.exports?(module, :__description__) do
      module.__description__
      |> Enum.map(fn field ->
        case field do
          {{key, type}, _default} when is_atom(key) and is_atom(type) ->
            {key, type}
          {key, type} when is_atom(key) and is_atom(type) ->
            field
          _ -> nil
        end
      end)
      |> Enum.filter(&(&1))
      |> Enum.into(%{})
      |> Map.merge(%{
        __index__: Integer,
        __origin_id__: String
      })
    else
      %{ origin: Origin }
    end
  end

  def init_morphs(%RingState{} = state) do
    morph_map =
      state.ring_module.__description__()
      |> Enum.map(fn {{key, _type}, _value} -> {key, []} end)
      |> Enum.into(%{})

    state.ring_module.__rules__()
    |> Enum.map(&({&1, morph_map}))
    |> Enum.into(%{})
  end

  def init_ring(%RingState{zone: zone, zone_id: zone_id, ring: ring} = state) do
    process_name = Core.process_name({{zone, zone_id}, ring})
    namespace = "#{CoreTable.base_name()}_#{process_name}"
    CoreTable.clear_namespace(namespace)

    state
    |> define_ring()
    |> struct(%{
      channels: %{},
      events_channel_name: "#{Core.process_name({zone, zone_id})}-events",
      morphs: init_morphs(state),
      members_table_name: "#{namespace}-members",
      morphs_table_name: "#{namespace}-morphs"
    })
  end

  defp add_member(member, %RingState{events_channel_name: channel_name} = state) do
    CoreTable.map_merge("#{state.members_table_name}:#{member.__index__}", member)
    CoreTable.async_publish(channel_name, ["add", "#{inspect state.ring}", member.__index__])

    state
    |> Map.put(:members, get_members(state) ++ [member])
    |> broadcast(:index_members, [{[member], state.attributes}])
  end

  defp get_members(%RingState{} = state) do
    state.members
  end

  defp get_member(member_index, %RingState{} = state) do
    get_members(state)
    |> Enum.find(&(&1.__index__ == member_index))
  end

  defp represent_member(fields, schema) do
    whitelist = Map.keys(schema)
    fields
    |> Enum.chunk(2)
    |> Enum.map(fn [key, value] ->
      case CoreTypes.cast(key, Atom, whitelist) do
        nil -> nil
        key -> {key, CoreTypes.cast(value, Map.get(schema, key))}
      end
    end)
    |> Enum.into(%{})
  end

  defp set_on_members(%RingState{members_table_name: members_table_name} = state, member_indices, changes) do
    schema =
      state.attributes
      |> Map.take(Map.keys(changes))
      |> Map.drop([:__index__, :__morphs__])

    member_indices
    |> Enum.map(&{:map_merge, ["#{members_table_name}:#{&1}", changes]})
    |> CoreTable.async_pipeline()

    CoreTable.async_publish(state.events_channel_name, ["update", "#{inspect state.ring}"] ++ member_indices)

    updated_members =
      only_indices(get_members(state), member_indices)
      |> Enum.map(fn member ->
        member
        |> Map.merge(member_changes(member, changes, schema, state))
      end)

    state
    |> Map.put(:members, exclude_indices(get_members(state), member_indices) ++ updated_members)
    |> broadcast(:show_members, [{updated_members, Map.put(schema, :__index__, Integer)}])
  end

  defp member_count(%RingState{members: members}) do
    length(members)
  end

  defp morph_members(%RingState{morphs: _morphs} = state, member_indices, rule, key, tween) do
    state
    |> freeze_morph(member_indices, rule, key)
    |> add_morph(member_indices, rule, key, tween)
  end

  defp cure_members(%RingState{morphs: morphs} = state, member_indices, rule, key) do
    updated_morphs =
      get_in(morphs, [rule, key])
      |> Enum.filter(fn {index, _tween} -> !Enum.member?(member_indices, index) end)

    state
    |> freeze_morph(member_indices, rule, key)
    |> struct(morphs: %{morphs | rule => %{morphs[rule] | key => updated_morphs}})
    |> broadcast(:drop_morphs, [rule, key, member_indices])
  end

  defp add_morph(%RingState{morphs: morphs} = state, member_indices, rule, key, tween) do
    updated_morphs =
      ((get_in(morphs, [rule, key]) || [])
      |> Enum.filter(fn {index, _tween} ->
        !Enum.member?(member_indices, index)
      end))
      ++ (Enum.map(member_indices, &{&1, tween}))

    state
    |> freeze_morph(member_indices, rule, key)
    |> broadcast(:show_morphs, [%{
      rule => %{key => updated_morphs}
    }])
    |> struct(morphs: %{morphs | rule => %{morphs[rule] | key => updated_morphs}})
  end

  defp freeze_morph(%RingState{morphs: morphs} = state, member_indices, rule, key) do
    updated_morphs =
      (get_in(morphs, [rule, key])
      |> Enum.map(fn {index, tween} ->
        {index, struct(tween, started_at: :os.system_time(:nanosecond))}
      end))

    state
    |> struct(%{
      morphs: %{morphs | rule => %{morphs[rule] | key => updated_morphs}},
      members: (
        get_members(state)
        |> Enum.filter(&(Enum.member?(member_indices, &1.__index__)))
        |> Enum.map(fn member ->
          tween = Enum.find(get_in(morphs, [rule, key]), fn {index, _tween} ->
            index == member.__index__
          end)
          case tween do
            {_index, %Exmorph.Tween{} = tween} ->
              %{member | key => member[key] + Exmorph.tween_value(tween)}
            _ -> member
          end
        end)
      ) ++ Enum.filter(get_members(state), &(!Enum.member?(member_indices, &1.__index__)))
    })
    |> show_members_attr(member_indices, key)
    |> broadcast(:show_morphs, [%{
      rule => %{key => updated_morphs}
    }])
  end

  def show_members_attr(%RingState{members: members} = state, _member_indices, key) do
    state
    |> broadcast(:show_members, [{members, Map.put(%{}, key, state.attributes[key])}])
  end

  defp remove_members(member_indices, %RingState{} = state) do
    member_indices
    |> Enum.map(&{:delete, ["#{state.members_table_name}:#{&1}"]})
    |> CoreTable.pipeline()

    CoreTable.async_publish(state.events_channel_name, ["drop", "#{inspect state.ring}"] ++ member_indices)

    state
    |> Map.put(:members, exclude_indices(get_members(state), member_indices))
    |> broadcast(:drop_members, [member_indices])
  end

  defp member_changes(%{} = member, %{} = changes, schema, %RingState{} = _state) do
    schema
    |> Enum.map(fn {key, type} ->
      cond do
        is_function(changes[key]) ->
          result = apply(changes[key], [member])

          {key, CoreTypes.cast({result, type})}
        true ->
          {key, CoreTypes.cast({changes[key], type})}
      end
    end)
    |> Enum.into(%{})
  end

  defp trigger(%RingState{} = state, event_name, event_params) do
    ring_event(state, event_params)
    |> Core.trigger(event_name)
    |> Core.dispatch

    state
  end

  defp ring_event(%RingState{} = state, %CoreEvent{} = event) do
    event
    |> struct(%{
      queue: [],
      ring: state.ring,
      zone: {state.zone, state.zone_id}
    })
  end
  defp ring_event(%RingState{} = state, params) do
    %CoreEvent{
      ring: state.ring,
      zone: {state.zone, state.zone_id}
    }
    |> struct(params)
  end

  defp broadcast(%RingState{zone: zone, zone_id: zone_id, name: ring_name, } = state, callback_key, args) do
    {:broadcast, apply(@factory, callback_key, [{zone, zone_id, ring_name}] ++ args)}
    |> CoreNetwork.cast(Core.pid({zone, zone_id}))

    state
  end

  defp define_ring(%RingState{} = state) do
    attributes =
      state.attributes
      |> Enum.map(fn {key, type} -> {key, CoreUtility.atom_to_string(type)} end)
      |> Enum.into(%{})

    CoreETS.insert({:ring, state.name, attributes})
    state
  end

  defp exclude_indices(members, indices) do
    Enum.filter(members, &(!Enum.member?(indices, &1.__index__)))
  end

  defp only_indices(members, indices) do
    Enum.filter(members, &(Enum.member?(indices, &1.__index__)))
  end

  defp new_member(%RingState{} = state, params) do
    state.ring_module.__description__()
    |> Enum.map(fn {{key, _type}, value} -> {key, value} end)
    |> Enum.into(%{})
    |> Map.merge(%{
      __index__: state.index,
      __origin_id__: nil
    })
    |> Map.merge(params)
  end
end
