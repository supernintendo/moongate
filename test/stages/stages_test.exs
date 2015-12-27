defmodule Moongate.Tests.Stages do
  alias Moongate.Tests.Helper, as: Helper
  use ExUnit.Case

  test "joining a stage and sending a message to it" do
    client = Helper.connect(self)
    login = Helper.defaults.login
    password = Helper.defaults.password

    # Login and wait until we've joined a stage.
    Helper.transaction client, %{
      send: "auth login #{login} #{password}",
      expect: "stage_test_stage░transaction░join"
    }
    assert_receive({:ok, _}, Helper.defaults.timeout)

    # Send a message to the stage
    Helper.transaction client, %{
      send: "test_stage test_message",
      expect: "Hear you, loud and clear!"
    }
    assert_receive({:ok, _}, Helper.defaults.timeout)

    Helper.disconnect(client)
  end
end
