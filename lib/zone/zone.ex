defmodule Moongate.Zone do
  use GenServer
  use Moongate.CoreState, :server

  def start_link(params) do
    %Moongate.ZoneState{}
    |> Map.merge(params)
    |> Moongate.CoreNetwork.establish(__MODULE__)
  end

  def handle_cast(:init, state) do
    # Moongate.CoreETS.insert({:zone, state.name, state.id})
    Moongate.Core.log({:zone, "Zone (#{state.name} #{state.id})"}, :up)

    {:noreply, init_rings(state)}
  end

  def handle_cast({:depart, origin}, state) do
    state =
      state
      |> apply_on_zone(:client_left, [new_event(state, %{targets: [origin]})])
      |> mutate({:remove_member, origin})
      |> commit_mutation(state)

    {:noreply, state}
  end

  def handle_call({:arrive, origin}, _from, state) do
    state =
      state
      |> notify_arrive(origin)
      |> apply_on_zone(:client_joined, [new_event(state, %{targets: [origin]})])
      |> mutate({:add_member, origin})
      |> commit_mutation(state)

    {:reply, :ok, state}
  end

  defp apply_on_zone(state, function_name, args) do
    apply(state.zone, function_name, args)
  end

  defp init_rings(state) do
    rings =
      state.zone
      |> apply(:__zone_rings, [])
      |> Enum.map(&(init_ring(&1, state)))
      |> Enum.into(%{})

    %{state | rings: rings}
  end

  defp init_ring(ring, state) do
    registered_name = Moongate.RingService.process_name({state.name, state.id, ring})

    %Moongate.RingState{
      attributes: Moongate.RingService.get_attributes(ring),
      name: Moongate.Core.atom_to_string(ring),
      ring: Moongate.RingService.ring_module(ring),
      zone: state.name,
      zone_id: state.id
    }
    |> Moongate.CoreNetwork.register(:ring, registered_name)

    {ring, registered_name}
  end

  defp notify_arrive(state, origin) do
    %Moongate.CorePacket{
      body: deed_names(state),
      domain: {:join, :zone},
      zone: {state.name, state.id}
    }
    |> Moongate.CoreNetwork.send_packet(origin)

    state
  end

  def notify_depart(state, _origin) do
    state
  end

  defp deed_names(state) do
    state.rings
    |> Map.keys
    |> Enum.map(&Moongate.Core.atom_to_string/1)
  end
end
