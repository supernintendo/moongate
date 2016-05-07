use Mix.Config

default_world = "default"
default_repo = "moongate:moongate@localhost/moongate"

case File.read("user") do
  {:ok, data} ->
    user_config = data |> String.split("\n")
    world = user_config |> hd
    repo = user_config |> tl |> hd
    config :moongate, Moongate.Repo, url: "ecto://#{repo}"
    config :moongate, world: world
  _ ->
    config :moongate, Moongate.Repo, url: "ecto://#{default_repo}"
    config :moongate, world: default_world
end
