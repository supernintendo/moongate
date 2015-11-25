defmodule Moongate.TCPSocket do
  defstruct port: nil
end

defmodule Moongate.Sockets.TCP.Socket do
  use GenServer
  use Moongate.Macros.Processes

  @doc """
    Listen for incoming socket messages on a port.
  """
  def start_link(port) do
    link(%Moongate.TCPSocket{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (TCP)...", :green)
    Socket.TCP.listen!(state.port, packet: 0)
    |> accept
  end

  # Accept a socket message.
  defp accept(listener) do
    uuid = UUID.uuid4(:hex)

    socket = Socket.TCP.accept!(listener)
    origin = %Moongate.SocketOrigin{
      id: uuid,
      ip: nil,
      port: socket,
      protocol: :tcp
    }
    {:ok, child} = spawn_new(:events, origin)
    spawn(fn -> handle(socket, &handler(&1, &2, uuid), uuid, child) end)
    Moongate.Say.pretty("Socket with id #{uuid} connected.", :magenta)
    accept(listener)
  end

  # Receive messages from a socket connection.
  defp handle(socket, handler, id, pid) do
    packet = Socket.Stream.recv!(socket)

    if packet == nil do
      # Client disconnects.
      Moongate.Say.pretty("Socket with id #{id} disconnected.", :black)
      kill_by_pid(:events, pid)
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
      {:error, error} when valid -> Moongate.Say.pretty("Bad packet `#{safe_packet}`: #{error}.", :red)
      {:error, error} -> Moongate.Say.pretty("Bad packet: #{error}.", :red)
      {:ok, parsed} -> tell_async(:events, id, {:event, parsed, {port, :tcp}})
    end
    ""
  end
end
