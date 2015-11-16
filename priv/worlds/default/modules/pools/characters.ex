defmodule Default.Pools.Character do
  import Moongate.Pool

  @move_transform %{
    mode: "linear",
    tag: "movement"
  }
  attributes %{
    name:       {:string, "a noob"},
    health:     {:int, 3},
    max_health: {:int, 3},
    speed:      {:float, 0.2},
    height:     {:int, 24},
    width:      {:int, 24},
    x:          {:float, 50.0},
    y:          {:float, 50.0}
  }
  cascades [
    {:sync_all, {:every, 3000}},
    {:sync_all, {:upon, Character, :create}},
    {:sync_all, {:upon, Character, :move}},
    {:sync_drop, {:upon, Character, :drop}}
  ]
  touches [
    {Character, :box, {:x, :y, :height, :width}}
  ]

  def move(event, params) do
    char = event.this
    move_char(char, params)
    bubble(event, :move)
  end

  def move_char(char, {x_delta, y_delta}) do
    speed = attr(char, :speed)

    if (x_delta < 0), do: mutate(char, :x, -speed, @move_transform)
    if (x_delta > 0), do: mutate(char, :x, speed, @move_transform)
    if (y_delta < 0), do: mutate(char, :y, -speed, @move_transform)
    if (y_delta > 0), do: mutate(char, :y, speed, @move_transform)
  end

  def touches(event, {Character, char}) do
  end

  def stop(event, params) do
    stop_char(event.this, params)
    bubble(event, :move)
  end

  def stop_char(char, {x_delta, y_delta}) do
    if (x_delta != 0), do: mutate(char, :x, 0, @move_transform)
    if (y_delta != 0), do: mutate(char, :y, 0, @move_transform)
  end

  def sync_all(event, params), do: sync_all(event)
  def sync_all(event) do
    packet = sync(event, Character, [:name, :x, :y])
    tell(event.this, packet)
  end

  def sync_drop(event, {char}) do
    packet = tagged(event, char, "drop")
    tell(event.this, packet)
  end

  def sync_one(event, params) do
    packet = sync(event, {Character, hd(params)}, [:name, :x, :y])
    tell(event.this, packet)
  end
end
