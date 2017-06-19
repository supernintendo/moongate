defmodule Test.Board do
  use Moongate.DSL, :zone

  rings [Entity]

  handle "start", ev do
    ev
  end

  handle "join", ev do
    ev
    |> create(Entity)
  end

  handle "leave", ev do
    ev
    |> purge(Entity, ev.origin)
  end

  handle "save", %{params: %{save_state: _save_state}} = ev do
    ev
  end
end
