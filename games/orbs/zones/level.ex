defmodule Orbs.Level do
  use Moongate.DSL, :zone

  rings [Player]

  handle "start", ev do
    ev
  end

  handle "join", ev do
    ev
    |> ping()
    |> echo("Welcome!")
    |> create(Player)
  end

  handle "leave", ev do
    ev
    |> purge(Player, ev.origin)
  end

  handle "save", %{params: %{save_state: _save_state}} = ev do
    ev
  end
end
