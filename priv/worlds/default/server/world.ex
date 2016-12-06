defmodule Default.World do
  use Moongate.DSL

  @doc "This is called when the server is started."
  def start do
  	zone(Level)
  end

  @doc "This is called when a client connects."
  def connected(event) do
  	event
  	|> join(Level)
  end
end
