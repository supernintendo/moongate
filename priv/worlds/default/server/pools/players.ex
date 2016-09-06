defmodule Default.Pool.Player do
  import Moongate.Pools

  attributes %{
    origin: :origin,
    x:      {:float, 0.0},
    y:      {:float, 0.0}
  }
  deeds [Movement]
  public [:origin, :x, :y]
end
