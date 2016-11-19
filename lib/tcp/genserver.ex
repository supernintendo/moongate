defmodule Moongate.TCP.GenServer do
  use GenServer
  use Moongate.Core

  @doc """
    Listen for incoming socket messages on a port.
  """
  def start_link(port) do
    %Moongate.Socket{
      port: port
    }
    |> establish
  end

  def handle_cast({:init}, state) do
    log(:up, {:socket, "TCP (#{state.port})"})
    Socket.TCP.listen!(state.port, packet: 0)
    |> accept
  end

  # Accept a socket message.
  defp accept(listener) do
    uuid = UUID.uuid4(:hex)

    socket = Socket.TCP.accept!(listener)
    origin = %Moongate.Origin{
      id: uuid,
      ip: nil,
      port: socket,
      protocol: :tcp
    }
    child = register(:session, origin)
    spawn(fn -> handle(socket, &handler(&1, &2, uuid), uuid, child) end)
    Moongate.Logger.Service.pretty("Socket with id #{uuid} connected.", :magenta)
    accept(listener)
  end

  # Receive messages from a socket connection.
  defp handle(socket, handler, id, pid) do
    packet = Socket.Stream.recv!(socket)

    if packet == nil do
      # Client disconnects.
      Moongate.Logger.Service.pretty("Socket with id #{id} disconnected.", :black)
      kill_pid(:session, pid)
      socket |> Socket.close
      :close
    else
      socket |> Socket.Stream.send!(handler.(packet, socket))
      handle(socket, handler, id, pid)
      :ok
    end
  end

  # Deal with a message received from a connected client.
  defp handler(packet, port, id) do
    safe_packet = Regex.replace(~r/[\n\b\t\r]/, packet, "")
    valid = String.valid?(safe_packet)

    case Moongate.Packets.parse(packet) do
      {:error, error} when valid -> Moongate.Logger.Service.pretty("Bad packet `#{safe_packet}`: #{error}.", :red)
      {:error, error} -> Moongate.Logger.Service.pretty("Bad packet: #{error}.", :red)
      {:ok, parsed} -> tell({:event, parsed, {port, :tcp}}, :session, id)
    end
    ""
  end
end
