defmodule Chat.Game do
  use Moongate.DSL, :game

  @doc "Called when the server is started."
  handle "start", ev do
    ev
    |> zone(Lobby, %{})
  end

  handle "begin", ev do
    ev
    |> join(Lobby)
  end

  handle "end", ev do
    ev
  end
end
