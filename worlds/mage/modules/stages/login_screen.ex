defmodule Mage.Stage.LoginScreen do
  import Moongate.Stage

  meta %{}
  takes :proceed, :check_authenticated

  def enrolled(_) do
  end

  defp check_authenticated(t, {}) do
    kick(t)
    enroll(t, :test_level)
  end
end