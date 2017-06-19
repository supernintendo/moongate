use Mix.Config

config :moongate,
  dev: Moongate.Dev,
  dsl: Moongate.DSL,
  file_watcher: "fswatch",
  game: (fn ->
    case Mix.env() do
      :test -> "test"
      _ -> System.get_env("MOONGATE_GAME") || "orbs"
    end
  end).(),
  game_path: (fn ->
    case Mix.env() do
      :test -> "test/support/game"
      _ -> System.get_env("MOONGATE_GAME_PATH") || "games/orbs"
    end
  end).(),
  generator: Moongate.Generator,
  logger: Moongate.Logger,
  packet: Moongate.Packet
