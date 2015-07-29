defmodule Scopes.Start do
  use Macros.Translator

  def on_load do
    spawn_new(:messages, "public")
  end
end