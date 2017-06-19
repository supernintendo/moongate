defmodule Moongate.DSL.Terms.DestroyTest do
  use ExUnit.Case, async: false
  alias Moongate.{
    Core,
    CoreEvent,
    DSL.Terms
  }

  setup_all do
    pid = Core.pid({{Board, "dsl_destroy_test"}, Entity})
    pid_2 = Core.pid({{Board, "dsl_destroy_test_2"}, Entity})
    GenServer.call(pid, {:add_member, %{}})
    GenServer.call(pid, {:add_member, %{}})
    GenServer.call(pid_2, {:add_member, %{string: "should remain"}})
    GenServer.call(pid_2, {:add_member, %{string: "should remain"}})
    GenServer.call(pid_2, {:add_member, %{}})

    {:ok, pid: pid, pid_2: pid_2}
  end

  test "Dispatcher.call/2 destroys ring members", context do
    {:ok, state} = GenServer.call(context.pid, :get_state)

    Destroy
    |> Terms.Destroy.Dispatcher.call(%CoreEvent{
      selected: {Entity, [0, 1]},
      zone: {Board, "dsl_destroy_test"}
    })

    {:ok, updated_state} = GenServer.call(context.pid, :get_state)
    assert length(state.members) == 2
    assert updated_state.members == []
  end

  test "Dispatcher.call/2 destroys a ring member, preserving the rest", context do
    {:ok, state} = GenServer.call(context.pid_2, :get_state)

    Destroy
    |> Terms.Destroy.Dispatcher.call(%CoreEvent{
      selected: {Entity, [2]},
      zone: {Board, "dsl_destroy_test_2"}
    })

    {:ok, updated_state} = GenServer.call(context.pid_2, :get_state)
    assert length(state.members) == 3
    assert length(updated_state.members) == 2
    assert Enum.all?(updated_state.members, &(&1.string == "should remain"))
  end

  test "&destroy/2" do
    result =
      %CoreEvent{
        zone: {Board, "dsl_destroy_test"},
        ring: Entity
      }
      |> Terms.Destroy.destroy()

    assert hd(result.queue) == {Destroy, 0}
  end
end
