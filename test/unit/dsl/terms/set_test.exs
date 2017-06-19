defmodule Moongate.DSL.Terms.SetTest do
  use ExUnit.Case, async: false
  alias Moongate.{
    Core,
    CoreEvent,
    DSL.Terms
  }

  setup_all do
    pid = Core.pid({{Board, "dsl_set_test"}, Entity})
    for _n <- 1..4, do: GenServer.call(pid, {:add_member, %{}})
    {:ok, member_indices} = GenServer.call(pid, {:get_member_indices, &(&1)})

    {:ok, member_indices: member_indices, pid: pid}
  end

  test "Dispatcher.call/2 sets ring member state", context do
    {:ok, members} =
      GenServer.call(context.pid, {:get_members, context.member_indices, %{}})

    {Set, %{float: 64.0, int: 256, string: "world"}}
    |> Terms.Set.Dispatcher.call(%CoreEvent{
      selected: {Entity, context.member_indices},
      zone: {Board, "dsl_set_test"}
    })

    {:ok, updated_members} =
      GenServer.call(context.pid, {:get_members, context.member_indices, %{}})

    refute Enum.any?(members, &(&1.float == 64.0))
    refute Enum.any?(members, &(&1.int == 256))
    refute Enum.any?(members, &(&1.string == "world"))
    assert Enum.all?(updated_members, &(&1.float == 64.0))
    assert Enum.all?(updated_members, &(&1.int == 256))
    assert Enum.all?(updated_members, &(&1.string == "world"))
  end

  test "Dispatcher.call/2 sets ring member state of a few members", context do
    {Set, %{float: 512.0, int: 1024, string: "virtue"}}
    |> Terms.Set.Dispatcher.call(%CoreEvent{
      selected: {Entity, [1, 2]},
      zone: {Board, "dsl_set_test"}
    })

    {:ok, members} =
      GenServer.call(context.pid, {:get_members, context.member_indices, %{}})

    refute Enum.all?(members, &(&1.float == 512.0))
    refute Enum.all?(members, &(&1.int == 1024))
    refute Enum.all?(members, &(&1.string == "virtue"))
    assert Enum.any?(members, &(&1.float == 512.0))
    assert Enum.any?(members, &(&1.int == 1024))
    assert Enum.any?(members, &(&1.string == "virtue"))
  end

  test "&set/2" do
    result =
      %CoreEvent{zone: {Board, "dsl_set_test"}, ring: Entity}
      |> Terms.Set.set(%{
        float: 128.0,
        string: "foo"
      })

    assert hd(result.queue) == {{Set, %{
      float: 128.0,
      string: "foo"
    }}, 0}
  end

  test "&set/3" do
    result =
      %CoreEvent{zone: {Board, "dsl_set_test"}, ring: Entity}
      |> Terms.Set.set(:string, "bar")

    assert hd(result.queue) == {{Set, %{string: "bar"}}, 0}
  end
end
