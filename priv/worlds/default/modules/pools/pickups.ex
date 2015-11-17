defmodule Default.Pools.Pickup do
  import Moongate.Pool

  attributes %{
    item:   {:string, ""},
    height: {:int, 32},
    width:  {:int, 32},
    x:      {:float, 0},
    y:      {:float, 0}
  }
  cascades [
    {:sync_all, {:upon, Pickup, :create}}
  ]
  touches []

  def sync_all(event, params), do: sync_all(event)
  def sync_all(event) do
    packet = sync(event, Pickup, [:x, :y, :item])
    bubble(%{event | params: {packet}}, :sync)
  end
end
