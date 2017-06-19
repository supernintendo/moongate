defmodule Moongate.CoreLoaderTest do
  use ExUnit.Case
  alias Moongate.CoreLoader

  test "&load_config/0" do
    result = CoreLoader.load_config()

    assert result.__struct__ == Moongate.CoreConfig
    assert result.endpoints
    assert result.log
    assert result.log.__struct__ == Moongate.CoreConfig.Log
    assert result.log.console
    assert result.log.default
    assert result.log.console.__struct__ == Moongate.CoreConfig.LogSettings
    assert result.log.default.__struct__ == Moongate.CoreConfig.LogSettings
    assert result.logger_mode
  end
end
