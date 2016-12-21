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

  @doc "Used in test/unit/core/dsl_test.exs"
  def dsl_mutation_test(event, :all) do
    event
    |> join(TestZone)
    |> subscribe(TestRing)
    |> target(&(&1))
    |> set(%{test_attr: :float})
  end
  def dsl_mutation_test(event, :join) do
    {join(event, TestZone), join(event, TestZone, "TestZoneName")}
  end
  def dsl_mutation_test(event, :set) do
    event
    |> set(%{test_attr: :float})
  end
  def dsl_mutation_test(event, :subscribe) do
    event
    |> subscribe(TestRing)
  end
  def dsl_mutation_test(event, :target) do
    event
    |> target(&(&1))
  end
  def dsl_mutation_test(_event, :zone) do
    zone(TestZone, "FooBar")
  end
end
