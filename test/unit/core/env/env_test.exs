defmodule Moongate.CoreEnvTest do
  use ExUnit.Case
  alias Moongate.CoreFirmware

  test "&codename/0" do
    expected_codename =
      File.read!("priv/manifest/codename")
      |> String.strip()

    assert CoreFirmware.codename() == expected_codename
  end

  test "&game_name/0" do
    assert CoreFirmware.game_name() == "test"
  end

  test "&version/0" do
    expected_version =
      File.read!("priv/manifest/version")
      |> String.strip()

    assert CoreFirmware.version() == expected_version
  end
end
