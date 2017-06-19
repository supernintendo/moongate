defmodule Moongate.DSL.Terms.LogTest do
  alias Moongate.{
    Core,
    CoreEvent,
    DSL.Terms
  }
  use ExUnit.Case
  import Mock

  test "Dispatcher.call/2 logs a message" do
    ev = %CoreEvent{}

    with_mock Core, [log: fn _ -> nil end] do
      Terms.Log.Dispatcher.call({Log, "vendor buy"}, ev)
      assert called Core.log({:info, "vendor buy"})
    end
  end

  test "&log/2" do
    result = Terms.Log.log(%CoreEvent{}, "guards")

    assert result.queue == [{{Log, "guards"}, 0}]
  end
end
