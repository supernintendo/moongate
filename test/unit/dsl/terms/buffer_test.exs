defmodule Moongate.DSL.Terms.BufferTest do
  use ExUnit.Case
  alias Moongate.{
    CoreEvent,
    DSL.Terms
  }

  defp construct_event(message) do
    pid = self()
    %CoreEvent{}
    |> Terms.Function.function(fn ev -> refute ev end) # This should never be called - Buffer drops head of queue
    |> Terms.Function.function(fn ev -> send(pid, message) && ev end)
  end

  test "Dispatcher.call/2 sends events after a period of time" do
    Terms.Buffer.Dispatcher.call({Buffer, {10, :milliseconds}}, construct_event("hello world"))
    Terms.Buffer.Dispatcher.call({Buffer, {50, :milliseconds}}, construct_event("corp por"))
    Terms.Buffer.Dispatcher.call({Buffer, {1, :seconds}}, construct_event("recdu recsu"))
    assert_receive "hello world"
    assert_receive "corp por"
    assert_receive "recdu recsu", 2_000
  end

  test "&buffer/2" do
    result = Terms.Buffer.buffer(%CoreEvent{}, {1_000, :milliseconds})

    assert hd(result.queue) == {{Buffer, {1_000, :milliseconds}}, 0}
  end
end
