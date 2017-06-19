defmodule Moongate.DSL.Terms.TargetTest do
  use ExUnit.Case
  alias Moongate.{
    CoreEvent,
    CoreOrigin,
    DSL.Terms
  }

  @origin %CoreOrigin{id: "target_test"}
  @origin_2 %CoreOrigin{id: "target_test_2"}

  test "Dispatcher.call/2 add an origin to targets list" do
    result =
      {Target, @origin}
      |> Terms.Target.Dispatcher.call(%CoreEvent{})

    assert result.targets == [@origin]
  end

  test "Dispatcher.call/2 add an origin to targets list, preserving the rest" do
    result =
      {Target, @origin_2}
      |> Terms.Target.Dispatcher.call(%CoreEvent{targets: [@origin]})

    assert result.targets == [@origin, @origin_2]
  end

  test "Dispatcher.call/2 add a list of origins to targets list" do
    result =
      {Target, [@origin, @origin_2]}
      |> Terms.Target.Dispatcher.call(%CoreEvent{})

    assert result.targets == [@origin, @origin_2]
  end

  test "Dispatcher.call/2 prevents duplicate targets" do
    result =
      {Target, @origin}
      |> Terms.Target.Dispatcher.call(%CoreEvent{targets: [@origin]})

    assert result.targets == [@origin]
  end

  test "target/2" do
    result = Terms.Target.target(%CoreEvent{}, @origin)
    result_2 = Terms.Target.target(%CoreEvent{}, [@origin, @origin_2])

    assert hd(result.queue) == {{Target, @origin}, 0}
    assert hd(result_2.queue) == {{Target, [@origin, @origin_2]}, 0}
  end
end
