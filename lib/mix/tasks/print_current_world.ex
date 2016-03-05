defmodule Mix.Tasks.Moongate.Current do
  @shortdoc "Prints the currently selected world."
  use Mix.Task

  def run(_) do
    Mix.shell.info Application.get_env(:moongate, :world)
  end
end
