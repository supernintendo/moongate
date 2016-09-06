defmodule Moongate.Socket.WebSocket.Node do
  use GenServer
  use Moongate.OS

  def start_link(port) do
    %Moongate.Socket{
      port: port
    }
    |> establish("socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    log(:up, {:socket, "WebSocket (#{state.port})"})
    server = Socket.Web.listen!(state.port) |> accept
    {:noreply, server}
  end

  # Accept a socket message.
  defp accept(listener) do
    client = listener |> Socket.Web.accept!
    client |> Socket.Web.accept!

    events = register(:session, %Moongate.Origin{
      id: UUID.uuid4(:hex),
      ip: nil,
      port: client,
      protocol: :web
    })
    spawn(fn -> handle(events, client) end)

    accept(listener)
  end

  # Receive messages from a socket connection.
  defp handle(events, client) do
    case client |> Socket.Web.recv! do
      {:text, packet} ->
        safe_packet = Regex.replace(~r/[\n\b\t\r]/, packet, "")
        valid = String.valid?(safe_packet)

        case Moongate.Packets.parse(packet) do
          {:error, error} when valid -> Moongate.Say.pretty("Bad packet #{safe_packet}: #{error}.", :red)
          {:error, error} -> Moongate.Say.pretty("Bad packet: #{error}.", :red)
          {:ok, parsed} -> tell_pid({:event, parsed, {client, :web}}, events)
        end

        handle(events, client)
      _ ->
        ask_pid(:cleanup, events)
        kill_pid(:session, events)
    end
  end
end
