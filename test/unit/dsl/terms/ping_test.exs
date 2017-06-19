defmodule Moongate.DSL.Terms.PingTest do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    CoreOrigin,
    DSL.Terms
  }
  use ExUnit.Case
  import Mock

  @origin %CoreOrigin{id: "ping_test"}

  test "Dispatcher.call/2 sends a ping packet" do
    ev = %CoreEvent{targets: [@origin]}

    with_mock CoreNetwork, [send_packet: fn _, _ -> nil end] do
      Terms.Ping.Dispatcher.call(Ping, ev)
      assert called CoreNetwork.send_packet(:_, ev.targets)
    end
  end

  test "&ping/2" do
    result = Terms.Ping.ping(%CoreEvent{})

    assert hd(result.queue) == {Ping, 0}
  end
end
