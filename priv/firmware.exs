%{
  codename: File.read!("priv/manifest/codename") |> String.trim(),
  description: "Multiplayer game server and SDK",
  elixir_version: File.read!("priv/manifest/elixir_version") |> String.trim(),
  game_name: (fn ->
    case Mix.env() do
      :test -> "test"
      _ -> System.get_env("MOONGATE_GAME") || "orbs"
    end
  end).(),
  game_path: (fn ->
    cond do
      Mix.env() == :test -> "test/support/game"
      File.dir?(System.get_env("MOONGATE_GAME_PATH")) ->
        System.get_env("MOONGATE_GAME_PATH")
      File.dir?("./games/#{System.get_env("MOONGATE_GAME_PATH")}") ->
        "./games/#{System.get_env("MOONGATE_GAME_PATH")}"
      true ->
        "orbs"
    end
  end).(),
  rust_libs: %{
    packets: %{}
  },
  version: File.read!("priv/manifest/version") |> String.trim()
}
