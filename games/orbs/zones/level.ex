defmodule Orbs.Level do
  use Moongate.DSL, :zone

  rings [Player]

  handle "start", ev do
    ev
  end

  handle "join", ev do
    ev
    |> echo("Welcome!")
    |> create(Player)
  end

  handle "leave", ev do
    ev
    |> purge(Player, ev.origin)
  end
end
