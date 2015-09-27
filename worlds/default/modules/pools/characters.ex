defmodule Default.Pools.Character do
  import Moongate.Pool

  attributes %{
    name:       {:string, ""},
    health:     {:int, 3},
    max_health: {:int, 3},
    speed:      {:int, 4},
    x:          {:int, 50},
    y:          {:int, 50}
  }
  triggers [
    {:refresh, {:in_response_to, Character, [:init, :move]}},
    {:refresh, {:every, 1000}}
  ]

  def refresh(e) do
    characters = batch e, Character, [:name, :x, :y]
    tell e.this, characters
  end
end
