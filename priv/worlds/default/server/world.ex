defmodule Default.World do
  import Moongate

  @doc """
    This is called when the server
    is started.
  """
  def start do
    stage(LoginScreen)
    stage(Level)
  end

  @doc """
    This is called when a client connects
    to the server.
  """
  def connected(event) do
    event
    |> arrive(LoginScreen)
  end
end
