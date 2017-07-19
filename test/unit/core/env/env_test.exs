defmodule Moongate.CoreEnvTest do
  use ExUnit.Case
  alias Moongate.CoreBootstrap

  test "&codename/0" do
    expected_codename =
      File.read!("priv/manifest/codename")
      |> String.trim()

    assert CoreBootstrap.codename() == expected_codename
  end

  test "&game_name/0" do
    assert CoreBootstrap.game_name() == "test"
  end

  test "&version/0" do
    expected_version =
      File.read!("priv/manifest/version")
      |> String.trim()

    assert CoreBootstrap.version() == expected_version
  end
end
