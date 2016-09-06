use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic
default_world = "default"

case File.read("priv/temp/user") do
  {:ok, data} ->
    user_config = data |> String.split("\n")
    world = user_config |> hd
    config :moongate, world: world
  _ ->
    config :moongate, world: default_world
end
