defmodule Moongate.UDPSocket do
  defstruct port: nil
end

defmodule Moongate.Sockets.UDP.Socket do
  use GenServer
  use Moongate.Macros.Processes

  def start_link(port) do
    link(%Moongate.UDPSocket{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (UDP)...", :green)
    {:ok, server} = Socket.UDP.open(state.port)
    server |> udp_listen
    {:noreply, server}
  end

  def handler({packet, {ip, port}}, server) do
    safe_packet = Regex.replace(~r/[\n\b\t\r]/, packet, "")
    valid = String.valid?(safe_packet)

    case Moongate.Packets.parse(packet) do
      {:error, error} when valid -> Moongate.Say.pretty("Bad packet #{safe_packet}: #{error}.", :red)
      {:error, error} -> Moongate.Say.pretty("Bad packet: #{error}.", :red)
      {:ok, parsed} ->
        unless pid_for_name(:events, "#{port}") do
          spawn_new(:events, %Moongate.SocketOrigin{
            id: port,
            ip: ip,
            port: server,
            protocol: :udp
          })
        end
        tell({:event, parsed, {server, :udp, ip}}, :events, "#{port}")
    end

    server |> udp_listen
  end

  def udp_listen(server) do
    server |> Socket.Datagram.recv! |> handler(server)
  end
end
