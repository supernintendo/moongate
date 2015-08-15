defmodule Moongate.HTTP.Router do
  use Cauldron

  def handle("GET", %URI{path: "/"}, req) do
    req |> Request.reply(200, "Hello, World!")
  end
end