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
    uuid = UUID.uuid4(:hex)
    client = listener |> Socket.Web.accept!
    client |> Socket.Web.accept!

    spawn_new(:events, %Moongate.SocketOrigin{
      id: uuid,
      ip: nil,
      port: client,
      protocol: :web
    })
    spawn(fn -> handle(client, uuid) end)
    accept(listener)
  end

  # Receive messages from a socket connection.
  defp handle(client, id) do
    case client |> Socket.Web.recv! do
      {:text, packet} ->
        safe_packet = Regex.replace(~r/[\n\b\t\r]/, packet, "")
        valid = String.valid?(safe_packet)

        case Moongate.Packets.parse(packet) do
          {:error, error} when valid -> Moongate.Say.pretty("Bad packet #{safe_packet}: #{error}.", :red)
          {:error, error} -> Moongate.Say.pretty("Bad packet: #{error}.", :red)
          {:ok, parsed} ->
            tell_async(:events, "#{id}", {:event, parsed, {client, :web}})
        end

        handle(client, id)
      _ ->
        Moongate.Say.pretty("Socket with id #{id} disconnected.", :magenta)
        tell_sync(:events, id, :cleanup)
        kill_by_id(:events, id)
    end
  end
end
