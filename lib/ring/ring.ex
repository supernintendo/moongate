defmodule Moongate.Ring do
  use GenServer
  alias Moongate.{
    Core,
    CoreETS,
    CoreEvent,
    CoreNetwork,
    CoreTypes,
    CoreUtility,
    RingState,
    Zone
  }

  @factory Application.get_env(:moongate, :packet).factory

  def start_link(%RingState{} = state, _name) do
    GenServer.start_link(__MODULE__, state)
  end

  def handle_cast(:init, %RingState{} = state) do
    zone_name = Zone.format_name({state.zone, state.zone_id})
    Core.log({:ring, "Ring {{#{zone_name}}, #{state.name}}"}, :up)

    {:noreply, init_ring(state)}
  end

  def handle_cast({:trigger, handler_name, event}, %RingState{} = state) do
    trigger(state, handler_name, event)

    {:noreply, state}
  end

  def handle_call({:add_member, params}, _from, %RingState{} = state) do
    state =
      new_member(state, params)
      |> add_member(state)

    {:reply, :ok, %{state | index: state.index + 1}}
  end

  def handle_call({:establish, origin}, _from, %RingState{zone: zone, zone_id: zone_id, name: ring_name} = state) do
    @factory.show_morphs({zone, zone_id, ring_name}, state.morphs)
    |> CoreNetwork.send_packet(origin)

    if length(state.members) > 0 do
      @factory.index_members({zone, zone_id, ring_name}, {state.members, state.attributes})
      |> CoreNetwork.send_packet(origin)
    end

    {:reply, :ok, state}
  end

  def handle_call(:get_count, _from, %RingState{} = state) do
    {:reply, {:ok, length(state.members)}, state}
  end

  def handle_call({:get_member_indices, condition}, _from, %RingState{} = state) do
    results =
      Enum.filter(state.members, condition)
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
      Enum.filter(state.members, condition)
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
      member_indices
      |> set_on_members(changes, state)

    {:reply, :ok, state}
  end

  def handle_call({:morph_members, member_indices, rule, key, tween}, _from, %RingState{} = state) do
    state =
      member_indices
      |> morph_members(rule, key, tween, state)

    {:reply, :ok, state}
  end

  def handle_call({:cure_members, member_indices, rule, key}, _from, %RingState{} = state) do
    state =
      member_indices
      |> cure_members(rule, key, state)

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

  def init_ring(%RingState{} = state) do
    state
    |> define_ring()
    |> struct(morphs: init_morphs(state))
  end

  defp add_member(member, %RingState{} = state) do
    state
    |> Map.put(:members, state.members ++ [member])
    |> broadcast(:index_members, [{[member], state.attributes}])
  end

  defp get_member(member_index, %RingState{} = state) do
    state.members
    |> Enum.find(&(&1.__index__ == member_index))
  end

  defp set_on_members(member_indices, changes, %RingState{} = state) do
    schema =
      state.attributes
      |> Map.take(Map.keys(changes))
      |> Map.drop([:__index__, :__morphs__])

    updated_members =
      only_indices(state.members, member_indices)
      |> Enum.map(fn member ->
        member
        |> Map.merge(member_changes(member, changes, schema, state))
      end)

    state
    |> Map.put(:members, exclude_indices(state.members, member_indices) ++ updated_members)
    |> broadcast(:show_members, [{updated_members, Map.put(schema, :__index__, Integer)}])
  end

  defp morph_members(member_indices, rule, key, tween, %RingState{morphs: morphs} = state) do
    updated_morphs =
      get_in(morphs, [rule, key])
      ++ (Enum.map(member_indices, &{&1, tween}))
      |> Enum.uniq_by(fn {index, _tween} -> index end)

    state
    |> struct(morphs: %{morphs | rule => %{morphs[rule] | key => updated_morphs}})
    |> broadcast(:show_morphs, [%{
      rule => %{key => updated_morphs}
    }])
  end

  defp cure_members(member_indices, rule, key, %RingState{morphs: morphs} = state) do
    updated_morphs =
      get_in(morphs, [rule, key])
      |> Enum.filter(fn {index, _tween} -> !Enum.member?(member_indices, index) end)

    state
    |> struct(morphs: %{morphs | rule => %{morphs[rule] | key => updated_morphs}})
    |> broadcast(:show_morphs, [%{
      rule => %{key => updated_morphs}
    }])
  end

  defp remove_members(member_indices, %RingState{} = state) do
    state
    |> Map.put(:members, exclude_indices(state.members, member_indices))
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
