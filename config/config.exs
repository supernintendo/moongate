use Mix.Config

config :moongate,
  console: Moongate.Console,
  file_watcher: "fswatch",
  logger: Moongate.Logger,
  packets: %{
    encoder: Moongate.Packets.Encoder,
    decoder: Moongate.Packets.Decoder
  },
  session: Moongate.Session,
  world: System.get_env("MOONGATE_WORLD") || "default"