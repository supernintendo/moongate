defmodule Moongate.DSL.Terms.CommandTest do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    CoreOrigin,
    DSL.Terms
  }
  use ExUnit.Case
  import Mock

  @origin %CoreOrigin{id: "command_test"}

  test "Dispatcher.call/2 sends a command packet" do
    ev = %CoreEvent{targets: [@origin]}

    with_mock CoreNetwork, [send_packet: fn _, _ -> nil end] do
      Terms.Command.Dispatcher.call({Command, "effect", [:thunder]}, ev)
      assert called CoreNetwork.send_packet(:_, ev.targets)
    end
  end

  test "command/2" do
    result = Terms.Command.command(%CoreEvent{}, "disconnect")

    assert hd(result.queue) == {{Command, "disconnect", []}, 0}
  end

  test "command/3" do
    result = Terms.Command.command(%CoreEvent{}, "effect", :thunder)
    result_2 = Terms.Command.command(%CoreEvent{}, "effect", [:thunder])

    assert hd(result.queue) == {{Command, "effect", [:thunder]}, 0}
    assert hd(result_2.queue) == {{Command, "effect", [:thunder]}, 0}
  end

  test "command/4" do
    result = Terms.Command.command(%CoreEvent{}, "test", "arg1", "arg2")

    assert hd(result.queue) == {{Command, "test", ["arg1", "arg2"]}, 0}
  end
end
