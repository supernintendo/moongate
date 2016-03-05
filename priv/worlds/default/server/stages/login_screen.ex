defmodule Default.Stage.LoginScreen do
  import Moongate.Stage

  meta %{}
  pools []

  def arrival(_) do
  end

  def departure(_) do
  end

  def takes({"proceed", _params}, event) do
    authenticate(event)
  end

  def authenticate(event) do
    if is_authenticated?(event) do
      travel event, :test_level
    end
  end
end
