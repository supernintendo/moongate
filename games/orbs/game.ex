defmodule Orbs.Game do
  use Moongate.DSL, :game

  @doc "Called when the server is started."
  handle "start", ev do
    ev
    |> zone(Level, %{})
  end

  handle "begin", ev do
    ev
    |> join(Level)
  end

  handle "end", ev do
    ev
  end
end
