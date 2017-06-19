defmodule Moongate.DSL.Terms.RetargetTest do
  use ExUnit.Case
  alias Moongate.{
    CoreEvent,
    CoreOrigin,
    DSL.Terms
  }

  @origin %CoreOrigin{id: "retarget_test"}
  @origin_2 %CoreOrigin{id: "retarget_test_2"}
  @origin_3 %CoreOrigin{id: "retarget_test_3"}

  test "retarget/2" do
    result =
      %CoreEvent{targets: [@origin_2, @origin_3]}
      |> Terms.Retarget.retarget(@origin)

    [
      {{untarget, callback}, untarget_index},
      {{target, target_arg}, target_index}
    ] = result.queue

    assert untarget == Untarget
    assert is_function(callback)
    assert untarget_index == 0
    assert target == Target
    assert target_arg == @origin
    assert target_index == 1
  end
end
