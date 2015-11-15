defmodule Default.Stage.LoginScreen do
  import Moongate.Stage

  meta %{}
  pools []
  takes :proceed, :check_authenticated

  def arrival(_) do
  end

  def departure(_) do
    IO.puts "leaving"
  end

  defp check_authenticated(event, _) do
    auth = is_authenticated?(event)

    if auth do
      depart event
      arrive event, :test_level
    end
  end
end
