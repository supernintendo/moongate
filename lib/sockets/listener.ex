defmodule Props.SocketListener do
  defstruct port: nil
end

defmodule Sockets.Listener do
  use GenServer
  use Mixins.Packets

  @doc """
    Listen for incoming socket messages on a port.
  """
  def start_link(port) do
    GenServer.start_link(__MODULE__, %Props.SocketListener{port: port}, [name: String.to_atom("socket_#{port}")])
  end

  def handle_cast({:init}, state) do
    uuid = UUID.uuid4(:hex)

    Say.pretty("Listening on port #{state.port}...", :green)
    Socket.TCP.listen!(state.port, packet: 0)
    |> accept(&handler(&1, &2, uuid), uuid)
  end

  # Accept a socket message.
  defp accept(listener, handler, id) do
    socket = Socket.TCP.accept!(listener)
    spawn(fn -> handle(socket, handler, id) end)
    Say.pretty("Socket with id #{id} connected.", :blue)

    GenServer.call(:tree, {:spawn, :events, id})
    accept(listener, handler, id)
  end

  # Receive messages from a socket connection.
  defp handle(socket, handler, id) do
    packet = Socket.Stream.recv!(socket)

    if packet == nil do
      # Client disconnects.
      Say.pretty("Socket with id #{id} disconnected.", :magenta)
      socket |> Socket.close
      :close
    else
      socket |> Socket.Stream.send!(handler.(packet, socket))
      handle(socket, handler, id)
      :ok
    end
  end

  # Deal with a message received from a connected client.
  defp handler(packet, port, id) do
    incoming = packet_to_list(packet)

    GenServer.cast(String.to_atom("events_" <> id), {:event, tl(incoming), hd(incoming), port})
    ""
  end
end