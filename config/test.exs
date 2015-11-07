use Mix.Config

config :moongate, Moongate.Db.Repo, url: "ecto://moongate:moongate@localhost/moongate"
config :moongate, world: "test"
