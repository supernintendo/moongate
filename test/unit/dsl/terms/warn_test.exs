defmodule Moongate.DSL.Terms.WarnTest do
  alias Moongate.{
    Core,
    CoreEvent,
    DSL.Terms
  }
  use ExUnit.Case
  import Mock

  test "Dispatcher.call/2 logs a warning" do
    ev = %CoreEvent{}

    with_mock Core, [log: fn _ -> nil end] do
      Terms.Warn.Dispatcher.call({Warn, "hey listen"}, ev)
      assert called Core.log({:warning, "hey listen"})
    end
  end

  test "&warn/2" do
    result = Terms.Warn.warn(%CoreEvent{}, "hey listen")

    assert result.queue == [{{Warn, "hey listen"}, 0}]
  end
end
