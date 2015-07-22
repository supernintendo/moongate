defmodule UDPSocket do
  defstruct port: nil
end

defmodule Sockets.UDP.Socket do
  use Macros.Translator

  def start_link(port) do
    link(%UDPSocket{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Say.pretty("Listening on port #{state.port} (UDP)...", :green)
    {:ok, server} = Socket.UDP.open(state.port)
    udp_listen(server)
    {:noreply, server}
  end

  def log_packet({data, {ip, port}}, server) do
    IO.puts port
    IO.puts data
    udp_listen(server)
  end

  def udp_listen(server) do
    server |> Socket.Datagram.recv! |> log_packet(server)
  end
end