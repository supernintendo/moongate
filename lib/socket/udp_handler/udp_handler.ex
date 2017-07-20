defmodule Moongate.Socket.UDPHandler do
  alias Moongate.{
    CoreNetwork,
    CoreSession,
    SocketState
  }

  @packet Application.get_env(:moongate, :packet)

  def init(%SocketState{port: port} = state) do
    {:ok, udp_port} = :gen_udp.open(port)

    struct(state, socket: udp_port)
  end

  def handle({:udp, _socket, ip, port, data}, %SocketState{} = state) do
    process_name = udp_process_name(ip, port)

    case CoreNetwork.pid_for_name("session_#{process_name}") do
      nil ->
        origin = CoreNetwork.new_origin(self(), CoreNetwork.ip_string(ip), :web)
        %CoreSession{
          origin: origin
        }
        |> CoreNetwork.register(:session, process_name)
      _process ->
        {:client_packet, @packet.decoder.decode("#{data}")}
        |> CoreNetwork.cast("session_#{process_name}")
    end
    {:noreply, state}
  end

  # Ignore everything else
  def handle(_payload, %SocketState{} = state) do
    {:noreply, state}
  end

  defp udp_process_name(ip, port) do
    "#{CoreNetwork.ip_string(ip)}_#{port}"
  end
end
