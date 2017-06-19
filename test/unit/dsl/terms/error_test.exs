defmodule Moongate.DSL.Terms.ErrorTest do
  alias Moongate.{
    Core,
    CoreEvent,
    DSL.Terms
  }
  use ExUnit.Case
  import Mock

  test "Dispatcher.call/2 logs an error message and voids the event" do
    ev = %CoreEvent{}

    with_mock Core, [log: fn _ -> nil end] do
      result = Terms.Error.Dispatcher.call({Error, "oh no!"}, ev)
      assert called Core.log({:error, "oh no!"})
      assert result.void
    end
  end

  test "&error/2" do
    result = Terms.Error.error(%CoreEvent{}, "oh no!")

    assert result.queue == [{{Error, "oh no!"}, 0}]
  end
end
