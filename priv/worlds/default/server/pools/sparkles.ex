defmodule Default.Pools.Sparkle do
  import Moongate.Pool
  attributes %{
    x:            {:float, 50.0},
    y:            {:float, 50.0}
  }
  deeds []
  public [:x, :y]
end
