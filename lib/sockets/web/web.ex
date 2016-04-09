defmodule Moongate.WebSocket do
  defstruct port: nil
end

defmodule Moongate.Sockets.Web.Socket do
  use GenServer
  use Moongate.Macros.Processes

  def start_link(port) do
    link(%Moongate.WebSocket{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (WebSocket)...", :green)

    server = Socket.Web.listen!(state.port) |> accept
    {:noreply, server}
  end

  # Accept a socket message.
  defp accept(listener) do
    client = listener |> Socket.Web.accept!
    client |> Socket.Web.accept!

    events_listener = spawn_new(:events, %Moongate.SocketOrigin{
      id: UUID.uuid4(:hex),
      ip: nil,
      port: client,
      protocol: :web
    })
    spawn(fn -> handle(events_listener, client) end)

    accept(listener)
  end

  # Receive messages from a socket connection.
  defp handle(events_listener, client) do
    case client |> Socket.Web.recv! do
      {:text, packet} ->
        safe_packet = Regex.replace(~r/[\n\b\t\r]/, packet, "")
        valid = String.valid?(safe_packet)

        case Moongate.Packets.parse(packet) do
          {:error, error} when valid -> Moongate.Say.pretty("Bad packet #{safe_packet}: #{error}.", :red)
          {:error, error} -> Moongate.Say.pretty("Bad packet: #{error}.", :red)
          {:ok, parsed} -> tell_pid({:event, parsed, {client, :web}}, events_listener)
        end

        handle(events_listener, client)
      _ ->
        tell_pid!(:cleanup, events_listener)
        kill_by_pid(:events, events_listener)
    end
  end
end
