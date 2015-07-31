defmodule Scopes.Events do
  use Macros.Packets
  use Macros.Translator

  def take(event) do
    case event do
      %{ cast: :send, to: :messages } ->
        p = expect_from(event, {:message})
        tell_async(:messages, "public", {:message, p})
    end
  end
end