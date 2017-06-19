defmodule Moongate.DSL.Terms.VoidTest do
  alias Moongate.{
    CoreEvent,
    DSL.Terms
  }
  use ExUnit.Case

  test "Dispatcher.call/2 voids the event" do
    result = Terms.Void.Dispatcher.call(Void, %CoreEvent{})

    assert result.void
  end

  test "&look/1" do
    result = Terms.Void.void(%CoreEvent{})

    assert result.queue == [{Void, 0}]
  end
end
