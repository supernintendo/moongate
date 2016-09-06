defmodule Default.World do
  import Moongate.Worlds

  @doc "This is called when the server is started."
  def start, do: stage(Level)

  @doc "This is called when a client connects to the server."
  def connected(event), do: event |> arrive(Level)
end
