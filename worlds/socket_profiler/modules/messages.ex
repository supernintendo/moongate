defmodule SocketProfiler.Messages do
  use Moongate.Macros.Translator
  use Moongate.Macros.SocketWriter

  def start_link(_) do
    link(%{}, "messages", "public")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("(SocketProfiler) Messages process started.", :cyan)
    {:noreply, state}
  end

  def handle_cast({:message, p}, state) do
    IO.puts "Message received from #{p.origin.id}: #{p.contents.message}"
    write_to(p.origin, %{
      cast: :message,
      namespace: :messages,
      value: "oh hai"
    })
    {:noreply, state}
  end
end
