defmodule Moongate.Macros.SocketWriter do
  def write_to(target, tag, message) do
    write_to(target, tag, :"#{Process.info(self)[:registered_name]}", message)
  end

  def write_to(target, tag, name, message) do
    GenServer.cast(target.events, {:write, tag, name, message})
  end

  def write_to_all(targets, tag, name, message) do
    for target <- targets do
      GenServer.cast(target.events, {:write, tag, name, message})
    end
  end
end
