defmodule Default.Pools.Player do
  import Moongate.Pool

  attributes %{
    origin:       :origin,
    x:            {:float, 0.0},
    y:            {:float, 0.0}
  }
  deeds [Movement]
  public [:origin, :x, :y]
end
