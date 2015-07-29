defmodule SocketProfiler.Messages do
  use Macros.Translator

  def start_link(_) do
    link(%{}, "messages", "public")
  end

  def handle_cast({:init}, state) do
    Say.pretty("(SocketProfiler) Messages process started.", :cyan)
    {:noreply, state}
  end
end
