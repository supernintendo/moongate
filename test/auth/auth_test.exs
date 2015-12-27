defmodule Moongate.Tests.Auth do
  alias Moongate.Tests.Helper, as: Helper
  use ExUnit.Case

  test "attempting to log in to an account that doesn't exist" do
    client = Helper.connect(self)
    Helper.transaction client, %{
      send: "auth login bad_email bad_password",
      expect: "doesn't exist"
    }
    assert_receive({:ok, message}, Helper.defaults.timeout)

    Helper.disconnect(client)
  end

  test "registering an account and logging into that account" do
    client = Helper.connect(self)
    login = "moongate_new_account"
    password = "test"

    # Make sure the user doesn't exist.
    Moongate.Tests.Helper.clean({:user, login})

    # Register
    Helper.transaction client, %{
      send: "auth register #{login} #{password}",
      expect: "been created"
    }
    assert_receive({:ok, _}, Helper.defaults.timeout)

    # Make sure user is not logged in
    Helper.transaction client, %{
      send: "auth is_logged_in #{login}",
      expect: "is not logged in"
    }
    assert_receive({:ok, _}, Helper.defaults.timeout)

    # Login
    Helper.transaction client, %{
      send: "auth login #{login} #{password}",
      expect: "logged in"
    }
    assert_receive({:ok, _}, Helper.defaults.timeout)

    # Make sure user is logged in
    Helper.transaction client, %{
      send: "auth is_logged_in #{login}",
      expect: "is logged in"
    }
    assert_receive({:ok, _}, Helper.defaults.timeout)

    Helper.disconnect(client)
  end
end
