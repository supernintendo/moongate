defmodule Default.Ring.Player do
  import Moongate.Rings

  attributes %{
    origin: :origin,
    x:      {:float, 0.0},
    y:      {:float, 0.0}
  }
  deeds [XY]
  public [:origin, :x, :y]
end