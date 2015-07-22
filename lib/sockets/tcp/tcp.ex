defmodule TCPSocket do
  defstruct port: nil
end

defmodule Sockets.TCP.Socket do
  use Macros.Packets
  use Macros.Translator

  @doc """
    Listen for incoming socket messages on a port.
  """
  def start_link(port) do
    link(%TCPSocket{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Say.pretty("Listening on port #{state.port} (TCP)...", :green)
    Socket.TCP.listen!(state.port, packet: 0)
    |> accept
  end

  # Accept a socket message.
  defp accept(listener) do
    uuid = UUID.uuid4(:hex)

    socket = Socket.TCP.accept!(listener)
    {:ok, child} = spawn_new(:events, uuid)
    spawn(fn -> handle(socket, &handler(&1, &2, uuid), uuid, child) end)
    Say.pretty("Socket with id #{uuid} connected.", :blue)
    accept(listener)
  end

  # Receive messages from a socket connection.
  defp handle(socket, handler, id, pid) do
    packet = Socket.Stream.recv!(socket)

    if packet == nil do
      # Client disconnects.
      Say.pretty("Socket with id #{id} disconnected.", :magenta)
      kill_by_pid(:events, pid)
      tell_async(:entity, id, {:disconnect})
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
    incoming = packet_to_list(packet)

    if hd(incoming) != :invalid_message do
      tell_async(:events, id, {:event, tl(incoming), hd(incoming), port})
    end
    ""
  end
end