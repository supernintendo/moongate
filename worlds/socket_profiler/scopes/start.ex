defmodule Moongate.Scopes.Start do
  use Moongate.Macros.Translator

  def on_load do
    spawn_new(:messages, "public")
  end
end