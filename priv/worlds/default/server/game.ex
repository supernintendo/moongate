defmodule Default.Game do
  import Moongate

  stages %{
    login_screen: Default.Stage.LoginScreen,
    test_level: Default.Stage.Level
  }

  @doc """
    This is called when a player connects
    to the server.
  """
  def connected(event) do
    event |> arrive!(:login_screen)
  end
end
