use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic
default_world = "default"

case System.get_env("MOONGATE_WORLD") do
  nil ->
    config :moongate, world: default_world
  world_name ->
    config :moongate, world: world_name
end
