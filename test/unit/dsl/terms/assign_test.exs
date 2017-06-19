defmodule Moongate.DSL.Terms.AssignTest do
  use ExUnit.Case
  alias Moongate.{
    CoreEvent,
    DSL.Terms
  }

  @data %{hp: 100, kal: "vas flam"}

  test "Dispatcher.call/2 assigns map" do
    result =
      {Assign, @data}
      |> Terms.Assign.Dispatcher.call(%CoreEvent{})

    assert result.assigns == @data
  end

  test "Dispatcher.call/2 merges map existing assigns" do
    changes = %{corp: "por"}
    result =
      {Assign, Map.merge(@data, changes)}
      |> Terms.Assign.Dispatcher.call(%CoreEvent{})

    assert result.assigns == Map.merge(@data, changes)
  end

  test "Dispatcher.call/2 assigns key value" do
    result =
      {Assign, :an, "corp"}
      |> Terms.Assign.Dispatcher.call(%CoreEvent{})

    assert result.assigns == %{an: "corp"}
  end

  test "Dispatcher.call/2 assigns key value to existing assigns" do
    result =
      {Assign, :an, "corp"}
      |> Terms.Assign.Dispatcher.call(%CoreEvent{assigns: @data})

    assert result.assigns == Map.put(@data, :an, "corp")
  end

  test "Dispatcher.call/2 assigns key value applies function" do
    result =
      {Assign, &(%{hp: &1.assigns.hp * 2})}
      |> Terms.Assign.Dispatcher.call(%CoreEvent{assigns: @data})

    assert result.assigns == %{@data | hp: 200}
  end

  test "assign/2" do
    result = Terms.Assign.assign(%CoreEvent{}, @data)

    assert hd(result.queue) == {{Assign, @data}, 0}
  end

  test "assign/3" do
    result = Terms.Assign.assign(%CoreEvent{}, :corp, "por")

    assert hd(result.queue) == {{Assign, :corp, "por"}, 0}
  end
end
