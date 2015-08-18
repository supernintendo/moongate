defmodule Moongate.Scopes.Events do
  use Moongate.Macros.Packets
  use Moongate.Macros.Translator

  def take(event) do
    case event do
      %{ cast: :send, to: :messages } ->
        tell_async(:messages, "public", {:message, event.params})
    end
  end
end