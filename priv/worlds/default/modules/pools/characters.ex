defmodule Default.Pools.Character do
  import Moongate.Pool

  @move_transform %{
    mode: "linear",
    tag: "movement"
  }
  attributes %{
    name:       {:string, "a noob"},
    speed:      {:float, 0.125},
    height:     {:int, 24},
    width:      {:int, 24},
    x:          {:float, 50.0},
    y:          {:float, 50.0},
    direction:  {:string, "up"},
    stance:     {:int, 0},

    archetype:  {:string, "elf"},
    attack:     {:int, 0},
    defense:    {:int, 0},
    health:     {:int, 3},
    max_health: {:int, 3},
    rupees:     {:int, 0}
  }
  cascades [
    {:sync_all, {:every, 200}},
    {:sync_all, {:upon, Character, :move}},
    {:sync_initial, {:upon, Character, :create}},
    {:sync_drop, {:upon, Character, :drop}},
    {:sync_pickups, {:upon, Pickup, :sync}}
  ]
  touches [
    {Projectile, :box, {:x, :y, :height, :width}}
  ]

  def move(event, params) do
    char = event.this
    speed = attr(char, :speed)
    set_direction(char, params)
    start_moving(char, params, speed)
    set(char, :stance, 1)
    bubble(event, :move)
  end

  def start_moving(char, {x_delta, y_delta}, speed) do
    cond do
      x_delta < 0 -> mutate(char, :x, -speed, @move_transform)
      y_delta < 0 -> mutate(char, :y, -speed, @move_transform)
      x_delta > 0 -> mutate(char, :x, speed, @move_transform)
      y_delta > 0 -> mutate(char, :y, speed, @move_transform)
    end
  end

  def set_direction(char, {x_delta, y_delta}) do
    cond do
      x_delta < 0 -> set(char, :direction, "left")
      y_delta < 0 -> set(char, :direction, "up")
      x_delta > 0 -> set(char, :direction, "right")
      y_delta > 0 -> set(char, :direction, "down")
    end
  end

  def touches(event, {Projectile, projectile}) do
  end

  def stop(event, params) do
    stop_moving(event.this, params)
    bubble(event, :move)
  end

  def stop_moving(char, {x_delta, y_delta}) do
    if (x_delta != 0), do: mutate(char, :x, 0, @move_transform)
    if (y_delta != 0), do: mutate(char, :y, 0, @move_transform)
    if (x_delta != 0 && y_delta != 0), do: set(char, :stance, 0)
  end

  # Sync

  def sync_all(event, params), do: sync_all(event)
  def sync_all(event) do
    packet = sync(event, Character, [:name, :x, :y, :direction, :stance])
    tell(event.this, packet)
  end

  def sync_initial(event, params), do: sync_all(event)
  def sync_initial(event) do
    packet = sync(event, Character, [
      :archetype,
      :direction,
      :health,
      :max_health,
      :name,
      :origin,
      :rupees,
      :stance,
      :x,
      :y,
    ])
    tell(event.this, packet)
  end

  def sync_drop(event, {char}) do
    packet = tagged(event, char, "drop")
    tell(event.this, packet)
  end

  def sync_one(event, params) do
    packet = sync(event, {Character, hd(params)}, [:name, :x, :y, :direction, :stance])
    tell(event.this, packet)
  end

  def sync_pickups(event, {packet}) do
    tell(event.this, packet)
  end
end
