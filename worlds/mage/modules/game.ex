defmodule Mage.Game do
  import Moongate

  stages %{
    login_screen: Mage.Stage.LoginScreen,
    test_level: Mage.Stage.Level
  }

  def connected(t) do
    enroll(t, :login_screen)
  end
end