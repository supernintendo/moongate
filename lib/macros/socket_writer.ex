defmodule Moongate.Macros.SocketWriter do
  def write_to(target, tag, message) do
    write_to(target, tag, Atom.to_string(Process.info(self())[:registered_name]), message)
  end

  def write_to(target, tag, name, message) do
    GenServer.cast(target.dispatcher, {:write, target, tag, name, message})
  end
end
