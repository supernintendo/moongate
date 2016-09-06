defmodule Moongate.Socket.UDP.Node do
  use GenServer
  use Moongate.OS

  def start_link(port) do
    %Moongate.Socket{
      port: port
    }
    |> establish("socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    {:ok, server} = Socket.UDP.open(state.port)
    server |> udp_listen

    log(:up, {:socket, "UDP (#{state.port})"})
    {:noreply, server}
  end

  # Handle an incoming datagram.
  defp handler({packet, {ip, port}}, server) do
    safe_packet = Regex.replace(~r/[\n\b\t\r]/, packet, "")
    valid = String.valid?(safe_packet)

    case Moongate.Packets.parse(packet) do
      {:error, error} when valid -> Moongate.Say.pretty("Bad packet #{safe_packet}: #{error}.", :red)
      {:error, error} -> Moongate.Say.pretty("Bad packet: #{error}.", :red)
      {:ok, parsed} ->
        unless pid_for_name("event_#{port}") do
          register(:session, %Moongate.Origin{
            id: port,
            ip: ip,
            port: server,
            protocol: :udp
          })
        end
        tell({:event, parsed, {server, :udp, ip}}, :session, "#{port}")
    end

    server |> udp_listen
  end

  # Listen for UDP datagrams.
  defp udp_listen(server) do
    server |> Socket.Datagram.recv! |> handler(server)
  end
end
