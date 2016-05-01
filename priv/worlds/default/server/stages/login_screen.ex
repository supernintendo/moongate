defmodule Default.Stage.LoginScreen do
  import Moongate.Stage

  meta %{}
  pools []

  def arrival(client) do
    client
  end

  def departure(client) do
    client |> depart
  end

  def takes({"proceed", _params}, client) do
    client |> authenticate
  end

  def authenticate(client) do
    if is_authenticated?(client) do
      client |> travel(:test_level)
    end
  end
end
