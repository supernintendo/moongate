defmodule Mix.Tasks.Moongate.KillExternalPids do
  use Mix.Task

  @shortdoc "Kills all processes started by the most recent Moongate instance"
  def run(args) do
    case args do
      [world_name | _] -> kill_external_pids(world_name)
      _ -> kill_external_pids("default")
    end
  end
  defp kill_external_pids(world) do
    {:ok, cache} = EON.from_file("priv/temp/#{world}.pids")

    cache[:pids]
    |> Enum.map(fn pid ->
      System.cmd("kill", ["#{pid}"])
      IO.puts "Moongate : OS pid #{pid} killed"
    end)
  end
end