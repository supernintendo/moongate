defmodule Moongate.DSL.Terms.UntargetTest do
  use ExUnit.Case
  alias Moongate.{
    CoreEvent,
    CoreOrigin,
    DSL.Terms
  }

  @origin %CoreOrigin{id: "untarget_test"}
  @origin_2 %CoreOrigin{id: "untarget_test_2"}
  @origin_3 %CoreOrigin{id: "untarget_test_3"}
  @origin_4 %CoreOrigin{id: "untarget_test_4"}

  test "Dispatcher.call/2 removes an origin from the targets list" do
    result =
      {Untarget, @origin}
      |> Terms.Untarget.Dispatcher.call(%CoreEvent{
        targets: [@origin]
      })

    assert result.targets == []
  end

  test "Dispatcher.call/2 removes an origin from the targets list, preserving the rest" do
    result =
      {Untarget, @origin_2}
      |> Terms.Untarget.Dispatcher.call(%CoreEvent{
        targets: [@origin, @origin_2]
      })

    assert result.targets == [@origin]
  end

  test "Dispatcher.call/2 removes a list of origins from the targets list" do
    result =
      {Untarget, [@origin, @origin_3]}
      |> Terms.Untarget.Dispatcher.call(%CoreEvent{
        targets: [@origin, @origin_2, @origin_3, @origin_4]
      })

    assert result.targets == [@origin_2, @origin_4]
  end

  test "untarget/2" do
    result = Terms.Untarget.untarget(%CoreEvent{}, @origin)
    result_2 = Terms.Untarget.untarget(%CoreEvent{}, [@origin, @origin_2])

    assert hd(result.queue) == {{Untarget, @origin}, 0}
    assert hd(result_2.queue) == {{Untarget, [@origin, @origin_2]}, 0}
  end
end
