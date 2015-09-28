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

  def refresh(event) do
    characters = batch event, Character, [:name, :x, :y]
    tell event.this, characters
  end
end
