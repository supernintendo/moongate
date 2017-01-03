use Mix.Config

config :moongate,
  console: Moongate.Console,
  dsl: Moongate.DSL,
  file_watcher: "fswatch",
  logger: Moongate.Logger,
  packets: Moongate.Packets,
  session: Moongate.Session,
  world: System.get_env("MOONGATE_WORLD") || "default"