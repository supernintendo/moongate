defmodule Moongate.Macros.SocketWriter do
  @doc """
    Send a message to an event process to be sent to the
    origin's socket.
  """
  def write_to(target, tag, message) do
    write_to(target, tag, :"#{Process.info(self)[:registered_name]}", message)
  end
  def write_to(target, tag, name, message) do
    GenServer.cast(target.events, {:write, tag, name, message})
  end

  @doc """
    Send a message to every event process in a list
    for each message to be sent to that event process'
    origin socket.
  """
  def write_to_all(targets, tag, name, message) do
    for target <- targets do
      GenServer.cast(target.events, {:write, tag, name, message})
    end
  end
end
