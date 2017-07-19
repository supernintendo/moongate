defmodule KillTrappedPids do
  require Logger

  def call do
    env = System.get_env("MOONGATE_ENV")
    game_name = System.get_env("MOONGATE_GAME")

    case System.cmd("redis-cli", ["--raw", "hvals", "mg_#{game_name}_#{env}-pids"]) do
      {output, 0} ->
        output
        |> String.split("\n")
        |> Enum.filter(&(&1 && String.trim(&1) != ""))
        |> Enum.map(&(System.cmd("kill", [&1])))
      _ ->
        nil
    end
  end
end

KillTrappedPids.call()
