defmodule Default.Stage.LoginScreen do
  import Moongate.Stage

  pools []

  def arrival(client) do
    client
  end

  def departure(client) do
    client
    |> depart
  end

  def takes({"proceed", _params}, client) do
    client
    |> authenticate
  end

  def authenticate(client) do
    if is_authenticated?(client) do
      client
      |> travel(Level)
    end
  end
end
