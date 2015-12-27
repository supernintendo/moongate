defmodule Moongate.Tests.HTTP do
  alias Moongate.Tests.Helper, as: Helper
  use ExUnit.Case

  test "requesting a web page over http" do
    port = Helper.defaults.http_port
    body = Helper.download('http://localhost:#{port}')
    assert String.contains?(body, "the test passed")
  end
end
