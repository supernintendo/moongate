defmodule Moongate.DSL.Terms.AttachTest do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    CoreOrigin,
    DSL.Terms
  }
  use ExUnit.Case
  import Mock

  @origin %CoreOrigin{id: "attach_test"}

  test "Dispatcher.call/2 sends an attach packet" do
    ev = %CoreEvent{targets: [@origin]}

    with_mock CoreNetwork, [send_packet: fn _, _ -> nil end] do
      Terms.Attach.Dispatcher.call({Attach, :corp, "por"}, ev)
      assert called CoreNetwork.send_packet(:_, ev.targets)
    end
  end

  test "attach/3" do
    result = Terms.Attach.attach(%CoreEvent{}, :corp, "por")

    assert hd(result.queue) == {{Attach, :corp, "por"}, 0}
  end
end
