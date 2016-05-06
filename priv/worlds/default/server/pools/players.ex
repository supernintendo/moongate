defmodule Default.Pools.Player do
  import Moongate.Pool

  attributes %{
    origin:       :origin,
    name:         {:string, "a noob"},
    speed:        {:float, 3.25},
    x:            {:float, 50.0},
    y:            {:float, 50.0},
    direction:    {:string, "up"}
  }
  deeds [Movement]
  public [:origin, :name, :x, :y, :direction]
end
