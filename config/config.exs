use Mix.Config

config :moongate,
  logger: Moongate.Logger,
  packets: %{
    encoder: Moongate.Packets.Encoder,
    decoder: Moongate.Packets.Decoder
  },
  session: Moongate.Session,
  world: System.get_env("MOONGATE_WORLD") || "default"

config :porcelain,
  driver: Porcelain.Driver.Basic