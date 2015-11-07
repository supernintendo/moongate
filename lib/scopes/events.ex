defmodule Moongate.Scopes.Events do
  @doc """
    This is called when a socket message is received by a
    client and the server has no defined way of dealing with
    it. This is overriden by the Moongate.Scopes.Events within
    the world's modules/scopes directory.
  """
  def take(_message) do
  end
end
