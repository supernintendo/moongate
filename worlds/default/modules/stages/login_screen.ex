defmodule Default.Stage.LoginScreen do
  import Moongate.Stage

  meta %{}
  pools %{}
  takes :proceed, :check_authenticated

  def joined(_) do
  end

  defp check_authenticated(t, {}) do
    auth = is_authenticated?(t)

    if auth do
      kick(t)
      join(t, :test_level)
    end
  end
end