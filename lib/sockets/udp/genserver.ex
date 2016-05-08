defmodule Moongate.Socket.UDP.GenServer do
  use GenServer
  use Moongate.Macros.Processes

  def start_link(port) do
    link(%Moongate.Socket.GenServer.State{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (UDP)...", :green, [suppress_timestamp: true])
    {:ok, server} = Socket.UDP.open(state.port)
    server |> udp_listen
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
        unless pid_for_name(:event, "#{port}") do
          spawn_new(:event, %Moongate.Origin{
            id: port,
            ip: ip,
            port: server,
            protocol: :udp
          })
        end
        tell({:event, parsed, {server, :udp, ip}}, :event, "#{port}")
    end

    server |> udp_listen
  end

  # Listen for UDP datagrams.
  defp udp_listen(server) do
    server |> Socket.Datagram.recv! |> handler(server)
  end
end
