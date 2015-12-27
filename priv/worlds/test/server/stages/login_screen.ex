defmodule Test.Stage.LoginScreen do
  import Moongate.Stage

  meta %{}
  pools []
  takes :proceed, :check_authenticated

  def arrival(_) do
  end

  defp check_authenticated(event, _) do
    auth = is_authenticated?(event)

    if auth do
      depart event
      arrive event, :test_stage
    end
  end
end
