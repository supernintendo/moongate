defmodule Test.World do
  use Moongate.DSL

  @doc "This is called when the server is started."
  def start do
    zone(TestZone)
  end

  @doc "This is called when a client connects."
  def connected(event) do
    event
    |> join(TestZone)
  end

  @doc "Used in test/unit/core/core_test.exs"
  def world_apply_helper do
    "It worked!"
  end
  def world_apply_helper(arg) do
    {"It worked!", arg}
  end
end
