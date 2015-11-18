defmodule Default.Pools.Particle do
  import Moongate.Pool

  @move_transform %{
    mode: "linear",
    tag: "movement"
  }
  attributes %{
    x:          {:float, 0},
    y:          {:float, 0},
    type:       {:string, ""},
    direction:  {:string, "default"},
    lifespan:   {:int, 400},
    time_alive: {:int, 0}
  }
  cascades [
    {:degrade, {:upon, Particle, :create}},
    {:sync_and_purge, {:every, 100}}
  ]
  touches []

  def degrade(event, params), do: degrade(event)
  def degrade(event) do
    p = event.this
    mutate(p, :time_alive, 1, %{
      mode: "linear",
      tag: "time"
    })
  end

  def sync_and_purge(event, params), do: sync_and_purge(event)
  def sync_and_purge(event) do
    p = event.this
    time_alive = attr(p, :time_alive)
    lifespan = attr(p, :lifespan)

    if time_alive > lifespan do
      packet = tagged(event, p, "drop")
      bubble(%{event | params: {packet}}, :sync)
      echo(event, {:drop})
    else
      packet = sync(event, Particle, [:x, :y, :type, :direction])
      bubble(%{event | params: {packet}}, :sync)
    end
  end
end
