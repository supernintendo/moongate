defmodule Moongate.DSL.Terms.EchoTest do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    CoreOrigin,
    DSL.Terms
  }
  use ExUnit.Case
  import Mock

  @origin %CoreOrigin{id: "echo_test"}

  test "Dispatcher.call/2 sends an echo packet" do
    ev = %CoreEvent{targets: [@origin]}

    with_mock CoreNetwork, [send_packet: fn _, _ -> nil end] do
      Terms.Echo.Dispatcher.call({Echo, "hello world"}, ev)
      assert called CoreNetwork.send_packet(:_, ev.targets)
    end
  end

  test "&echo/2" do
    result = Terms.Echo.echo(%CoreEvent{}, "hello world")
    result_2 = Terms.Echo.echo(%CoreEvent{}, &("hello #{&1.assigns.name}"))
    [{{echo, callback}, index}] = result_2.queue

    assert hd(result.queue) == {{Echo, "hello world"}, 0}
    assert echo == Echo
    assert is_function(callback)
    assert index == 0
  end
end
