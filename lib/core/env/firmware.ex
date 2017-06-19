defmodule Moongate.CoreFirmware do
  @firmware Eon.read_unsafe!("priv/firmware.exs")

  def codename, do: @firmware.codename
  def description, do: @firmware.description
  def elixir_version, do: @firmware.elixir_version
  def game_name, do: @firmware.game_name
  def game_path, do: @firmware.game_path
  def rust_libs, do: @firmware.rust_libs
  def version, do: @firmware.version
end
