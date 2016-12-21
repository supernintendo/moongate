defmodule Moongate.Tests.DSL do
  use ExUnit.Case, async: true

  alias Test.World

  test "DSL mutations" do
    terms = [:join_zone, :set, :subscribe_to_ring, :target]
    result =
      %Moongate.Event{}
      |> World.dsl_mutation_test(:all)
      |> Map.get(:__pending_mutations)
      |> Enum.map(&(&1 |> elem(1) |> elem(0)))
      |> Enum.sort

    assert terms == result
  end

  test "DSL `join`" do
    {join_a, join_b} =
      %Moongate.Event{}
      |> World.dsl_mutation_test(:join)

    result_a = hd(join_a.__pending_mutations)
    result_b = hd(join_b.__pending_mutations)

    assert {_timestamp_a, {:join_zone, TestZone, "$"}} = result_a
    assert {_timestamp_b, {:join_zone, TestZone, "TestZoneName"}} = result_b
  end

  test "DSL `set`" do
    result =
      %Moongate.Event{}
      |> World.dsl_mutation_test(:set)
      |> Map.get(:__pending_mutations)
      |> hd

    assert {_timestamp, {:set, %{test_attr: :float}}} = result
  end

  test "DSL `subscribe`" do
    result =
      %Moongate.Event{}
      |> World.dsl_mutation_test(:subscribe)
      |> Map.get(:__pending_mutations)
      |> hd

    assert {_timestamp, {:subscribe_to_ring, TestRing}} = result
  end

  test "DSL `target`" do
    result =
      %Moongate.Event{}
      |> World.dsl_mutation_test(:target)
      |> Map.get(:__pending_mutations)
      |> hd

    assert {_timestamp, {:target, fun}} = result
    assert is_function(fun)
  end

  test "DSL `zone`" do
    expected =  Moongate.ETS.index(:registry)
    World.dsl_mutation_test(%Moongate.Event{}, :zone)
    result = Moongate.ETS.index(:registry)

    refute Map.has_key?(expected, "zone_TestZone_FooBar")
    assert Map.has_key?(result, "zone_TestZone_FooBar")
  end
end