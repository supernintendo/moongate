use Mix.Config

config :moongate,
  dev: Moongate.Dev,
  dispatcher: Moongate.DSLDispatcher,
  dsl: Moongate.DSL,
  file_watcher: "fswatch",
  game: (
    (Mix.env() == :test && "test")
    || System.get_env("MOONGATE_GAME")
    || "orbs"
  ),
  game_path: (
    Mix.env() == :test && "test/support/game"
    || System.get_env("MOONGATE_GAME_PATH")
    || "games/orbs"
  ),
  generator: Moongate.Generator,
  logger: Moongate.Logger,
  packet: Moongate.Packet,
  table: Moongate.Redis
