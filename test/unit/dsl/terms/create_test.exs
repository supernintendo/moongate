defmodule Moongate.DSL.Terms.CreateTest do
  use ExUnit.Case, async: false
  alias Moongate.{
    Core,
    CoreEvent,
    DSL.Terms
  }

  setup_all do
    pid = Core.pid({{Board, "dsl_create_test"}, Entity})
    pid_2 = Core.pid({{Board, "dsl_create_test_2"}, Entity})

    {:ok, pid: pid, pid_2: pid_2}
  end

  test "Dispatcher.call/2 creates a ring member", context do
    {:ok, state} = GenServer.call(context.pid, :get_state)

    {Create, Entity, %{float: 8.0, int: 16, string: "item"}}
    |> Terms.Create.Dispatcher.call(%CoreEvent{
      zone: {Board, "dsl_create_test"}
    })

    {:ok, updated_state} = GenServer.call(context.pid, :get_state)
    assert state.members == []
    assert updated_state.members == [%{
      __index__: 0,
      __origin_id__: nil,
      float: 8.0,
      int: 16,
      string: "item"
    }]
  end

  test "Dispatcher.call/2 creates a ring member with default attributes", context do
    {:ok, state} = GenServer.call(context.pid_2, :get_state)

    {Create, Entity, %{}}
    |> Terms.Create.Dispatcher.call(%CoreEvent{
      zone: {Board, "dsl_create_test_2"}
    })

    {:ok, updated_state} = GenServer.call(context.pid_2, :get_state)
    assert state.members == []
    assert updated_state.members == [%{
      __index__: 0,
      __origin_id__: nil,
      float: 32.0,
      int: 128,
      string: "hello"
    }]
  end

  test "&create/2" do
    result =
      %CoreEvent{zone: {Board, "dsl_create_test"}, ring: Entity}
      |> Terms.Create.create(Entity, %{
        int: 100,
        string: "skill"
      })

    assert hd(result.queue) == {{Create, Entity, %{
      int: 100,
      string: "skill"
    }}, 0}
  end

  test "&create/3" do
    result =
      %CoreEvent{zone: {Board, "dsl_create_test"}, ring: Entity}
      |> Terms.Create.create(Entity, %{string: "bar"})

    assert hd(result.queue) == {{Create, Entity, %{string: "bar"}}, 0}
  end
end
