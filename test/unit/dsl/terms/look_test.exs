defmodule Moongate.DSL.Terms.LookTest do
  alias Moongate.{
    CoreEvent,
    DSL.Terms
  }
  use ExUnit.Case
  import Mock

  test "Dispatcher.call/2 inspects the packet" do
    ev = %CoreEvent{}

    with_mock IO, [puts: fn _ -> nil end] do
      Terms.Look.Dispatcher.call({Look, "label"}, ev)
      assert called IO.puts(:_)
    end
    with_mock Kernel, [inspect: fn _ -> nil end] do
      Terms.Look.Dispatcher.call(Look, ev)
      assert called Kernel.inspect(:_)
    end
  end

  test "&look/2" do
    result = Terms.Look.look(%CoreEvent{})
    result_2 = Terms.Look.look(%CoreEvent{}, "label")

    assert result.queue == [{Look, 0}]
    assert result_2.queue == [{{Look, "label"}, 0}]
  end
end
