defmodule Moongate.Tests.Auth do
  alias Moongate.Tests.Helper, as: Helper
  use ExUnit.Case

  test "attempting to log in to an account that doesn't exist" do
    client = Helper.connect(self)
    Helper.send_packet(client, "auth login bad_email bad_password")
    Helper.expect_packet(client, "doesn't exist", self)
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
    Helper.send_packet(client, "auth register #{login} #{password}")
    Helper.expect_packet(client, "been created", self)
    assert_receive({:ok, message}, Helper.defaults.timeout)

    # Make sure user is not logged in
    Helper.send_packet(client, "auth is_logged_in #{login}")
    Helper.expect_packet(client, "is not logged in", self)
    assert_receive({:ok, message}, Helper.defaults.timeout)

    # Login
    Helper.send_packet(client, "auth login #{login} #{password}")
    Helper.expect_packet(client, "logged in", self)
    assert_receive({:ok, message}, Helper.defaults.timeout)

    # Make sure user is logged in
    Helper.send_packet(client, "auth is_logged_in #{login}")
    Helper.expect_packet(client, "is logged in", self)
    assert_receive({:ok, message}, Helper.defaults.timeout)

    Helper.disconnect(client)
  end
end
