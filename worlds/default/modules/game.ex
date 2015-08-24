defmodule Default.Game do
  import Moongate

  stages %{
    login_screen: Default.Stage.LoginScreen,
    test_level: Default.Stage.Level
  }

  def connected(t) do
    join(t, :login_screen)
  end
end