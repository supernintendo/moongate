defmodule Orbs.Game do
  use Moongate.DSL, :game

  @doc "Called when the server is started."
  handle "start", ev do
    ev
    |> zone({Level, "lobby"}, %{})
  end

  handle "begin", ev do
    ev
    |> join(Level, "lobby")
  end

  handle "end", ev do
    ev
  end
end
