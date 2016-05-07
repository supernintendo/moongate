defmodule Mix.Tasks.Moongate.Loaded do
  @shortdoc "Prints the currently loaded world."
  use Mix.Task

  def run(_) do
    Application.get_env(:moongate, :world) |> Mix.shell.info
  end
end
