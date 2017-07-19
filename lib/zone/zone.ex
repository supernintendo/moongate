defmodule Moongate.Zone do
  alias Moongate.{
    Core,
    CoreETS,
    CoreEvent,
    CoreNetwork,
    CoreOrigin,
    CoreUtility,
    Ring,
    RingState,
    ZoneState
  }
  use GenServer

  def start_link(initial_state, _name) do
    state =
      %ZoneState{}
      |> Map.merge(initial_state)

    GenServer.start_link(__MODULE__, state)
  end

  def handle_info(:init, state) do
    Core.log({:zone, "Zone {#{format_name({state.zone, state.id})}}"}, :up)

    {:noreply, zone_init(state)}
  end

  def handle_info({:broadcast, packet}, state) do
    {:noreply, broadcast(packet, state)}
  end
  def handle_info({:leave, origin}, state) do
    {:noreply, member_leave(state, origin)}
  end
  def handle_info({:trigger, handler_name, event}, state) do
    {:noreply, trigger(state, handler_name, event)}
  end

  def handle_call({:leave, origin}, _from, state) do
    {:reply, :ok, member_leave(state, origin)}
  end
  def handle_call({:get_members, condition}, _from, state) when is_function(condition) do
    {:reply, {:ok, get_members(state, condition)}, state}
  end
  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end
  def handle_call(:info, _from, state) do
    {:reply, {:ok, zone_info(state)}, state}
  end
  def handle_call({:join, origin, assigns}, _from, state) do
    {:reply, :ok, member_join(state, origin, assigns)}
  end
  def handle_call({:save, event}, _from, state) do
    {:reply, :ok, zone_save(state, event)}
  end

  def format_name({zone_module, zone_name}) do
    "#{CoreUtility.atom_to_string(zone_module)}, \"#{zone_name}\""
  end

  def index do
    pids =
      CoreETS.index(:registry)
      |> Map.get("tree_zone")
      |> Supervisor.which_children
      |> Enum.map(&(elem(&1, 1)))

    case pids do
      pids when is_list(pids) ->
        CoreETS.index(:registry)
        |> Enum.filter(fn {_name, pid} -> Enum.member?(pids, pid) end)
        |> Enum.map(fn {name, pid} ->
          ["zone", zone_name | id] = String.split(name, "_")
          module_name = zone_name

          {{Module.safe_concat([module_name]), Enum.join(id, "_")}, pid}
        end)
        |> Enum.into(%{})
      _ ->
        []
    end
  end

  def get_members(%ZoneState{} = state, condition) when is_function(condition) do
    state.members
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.filter(condition)
  end

  def member_join(%ZoneState{} = state, %CoreOrigin{} = origin, assigns) do
    state
    |> Map.put(:members, Map.put(state.members, origin.id, origin))
    |> establish_rings_state(origin)
    |> trigger(:join, %{origin: origin, targets: [origin], assigns: assigns})
  end

  def member_leave(%ZoneState{} = state, %CoreOrigin{} = origin) do
    if Map.has_key?(state.members, origin.id) do
      state
      |> Map.put(:members, Map.delete(state.members, origin.id))
      |> trigger(:leave, %{origin: origin, targets: [origin]})
    else
      state
    end
  end

  def zone_init(state) do
    state
    |> define_zone()
    |> init_rings()
    |> init_zone()
  end

  def zone_save(%ZoneState{} = state, %CoreEvent{assigns: assigns} = event) do
    ring_state = call_on_all_rings(:get_state, state)
    state
    |> trigger(:save, struct(event, assigns: Map.put(assigns, :save_state, ring_state)))
  end

  # defp broadcast(packets, state) when is_list(packets) do
  #   Enum.map(packets, &(CoreNetwork.send_packet(&1, origins(state.members))))
  #   state
  # end
  defp broadcast(packet, state) do
    CoreNetwork.send_packet(packet, origins(state.members))
    state
  end

  defp call_on_all_rings(handler, state) do
    state.rings
    |> Enum.map(fn {key, value} ->
      case CoreNetwork.call(handler, "ring_#{value}") do
        {:ok, count} -> {key, count}
        _ -> {key, nil}
      end
    end)
    |> Enum.into(%{})
  end

  defp define_zone(state) do
    CoreETS.insert({:zone, CoreUtility.atom_to_string(state.zone), state.rings})
    state
  end

  defp establish_rings_state(state, origin) do
    state.rings
    |> Enum.map(fn {_key, value} ->
      CoreNetwork.call({:establish, origin}, "ring_#{value}")
    end)
    state
  end

  defp init_rings(state) do
    rings =
      Core.module(state.zone)
      |> apply(:__rings__, [])
      |> Enum.map(&(init_ring(&1, state)))
      |> Enum.into(%{})

    %{state | rings: rings}
  end

  defp init_ring(ring, state) do
    process_name = Core.process_name({{state.zone, state.id}, ring}, %{prefix: false})
    ring_module = Core.module(ring)

    %RingState{
      attributes: Ring.get_attributes(ring_module),
      name: CoreUtility.atom_to_string(ring),
      ring: ring,
      ring_module: ring_module,
      zone: state.zone,
      zone_id: state.id
    }
    |> CoreNetwork.register(:ring, process_name)

    {ring, process_name}
  end

  defp init_zone(state) do
    state
    |> trigger(:start, %{assigns: %{params: state.zone_params}})
  end

  defp origins(members) do
    members
    |> Enum.map(fn {_id, origin} -> origin end)
  end

  defp ring_pids(state) do
    state.rings
    |> Enum.map(fn {key, _value} ->
      {key, Core.pid({{state.zone, state.id}, key})}
    end)
    |> Enum.into(%{})
  end

  defp trigger(state, event_name, event_params) do
    zone_event(state, event_params)
    |> Core.trigger(event_name)
    |> Core.dispatch

    state
  end

  defp zone_event(state, %CoreEvent{} = event) do
    event
    |> struct(%{
      queue: [],
      zone: {state.zone, state.id}
    })
  end
  defp zone_event(state, params) do
    %CoreEvent{
      zone: {state.zone, state.id}
    }
    |> struct(params)
  end

  defp zone_info(state) do
    %{
      members: state.members,
      pids: %{
        rings: ring_pids(state),
        zone: self()
      },
      ring_counts: call_on_all_rings(:get_count, state),
      zone: state.zone
    }
  end
end
