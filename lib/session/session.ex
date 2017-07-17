defmodule Moongate.Session do
  use GenServer
  alias Moongate.{
    Core,
    CoreSession,
    CoreNetwork
  }

  @packet Application.get_env(:moongate, :packet)

  def start_link(%CoreSession{} = state, _name) do
    GenServer.start_link(__MODULE__, state)
  end

  def handle_info(:init, %CoreSession{} = state) do
    Core.log({:session, "Session (#{state.origin.ip})"}, :up)
    {:noreply, state}
  end

  def handle_info({:client_packet, packet}, %CoreSession{} = state) do
    packet
    |> packet_to_event(state)
    |> @packet.handler.handle_packet(state)

    {:noreply, state}
  end

  def handle_info({:grant_access, token}, %CoreSession{access: access} = state) do
    access =
      (access ++ [token])
      |> Enum.uniq()

    {:noreply, %{ state | access: access }}
  end

  def handle_info({:revoke_access, token}, %CoreSession{access: access} = state) do
    access =
      access
      |> Enum.filter(&(&1 != token))

    {:noreply, %{ state | access: access }}
  end

  def handle_call(:terminated, _from, %CoreSession{} = state) do
    CoreNetwork.cascade({:leave, state.origin}, :zone)
    Core.log({:session, "Session (#{state.origin.ip})"}, :down)

    {:reply, {:ok, self()}, state}
  end

  defp packet_to_event(packet, state) do
    %Moongate.CoreEvent{
      origin: state.origin,
      targets: []
    }
    |> Map.merge(packet)
  end
end
