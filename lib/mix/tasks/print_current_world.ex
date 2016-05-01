defmodule Mix.Tasks.Moongate.Current do
  @shortdoc "Prints the currently selected world."
  use Mix.Task

  def run(_) do
    Application.get_env(:moongate, :world) |> Mix.shell.info
  end
end
