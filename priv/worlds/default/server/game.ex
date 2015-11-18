defmodule Default.Game do
  import Moongate

  stages %{
    login_screen: Default.Stage.LoginScreen,
    test_level: Default.Stage.Level
  }

  def connected(event) do
    arrive event, :login_screen
  end
end
