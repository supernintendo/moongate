defmodule Default.Pools.Tile do
  import Moongate.Pool

  attributes %{
    x: {:int, 0},
    y: {:int, 0},
    color: {:string, "blue"}
  }
  conveys []
end
