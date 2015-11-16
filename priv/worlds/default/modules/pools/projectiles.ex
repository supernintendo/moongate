defmodule Default.Pools.Projectile do
  import Moongate.Pool

  @move_transform %{
    mode: "linear",
    tag: "movement"
  }
  attributes %{
    x: {:float, 0},
    y: {:float, 0},
    height: {:int, 6},
    width: {:int, 6},
    x_delta: {:float, 0},
    y_delta: {:float, 0}
  }
  cascades [
    {:sync_all, {:every, 400}}
  ]
  touches []

  def sync_all(event, params), do: sync_all(event)
  def sync_all(event) do
    packet = sync(event, Projectile, [:x, :y])
    bubble(%{event | params: {packet}}, :sync)
  end
end
