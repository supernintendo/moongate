defmodule Default.Pools.Player do
  import Moongate.Pool

  attributes %{
    origin:       :origin,
    name:         {:string, "a noob"},
    speed:        {:float, 0.125},
    x:            {:float, 50.0},
    y:            {:float, 50.0},
    direction:    {:string, "up"}
  }
  deeds [Movement, Test]
  publishes [:name, :x, :y, :direction]
  subscribes %{
    Player: [
      "foo": {Test, :bar}
    ]
  }
end
