defmodule Moongate.CoreBootstrap do
  @bootstrap Eon.read_unsafe!("priv/bootstrap.exs")

  def codename, do: @bootstrap.codename
  def description, do: @bootstrap.description
  def elixir_version, do: @bootstrap.elixir_version
  def game_name, do: @bootstrap.game_name
  def game_path, do: @bootstrap.game_path
  def version, do: @bootstrap.version
end
