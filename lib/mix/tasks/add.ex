defmodule Mix.Tasks.Moongate.Add do
  @shortdoc """
    Creates a symlink to the specified directory
    within priv/worlds, allowing it to be loaded
    with mix moongate.load.
  """
  use Mix.Task

  def run(args) do
    IO.inspect args
  end
end
