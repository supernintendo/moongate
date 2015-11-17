defmodule Default.Pools.Character do
  import Moongate.Pool

  @move_transform %{
    mode: "linear",
    tag: "movement"
  }
  attributes %{
    name:       {:string, "a noob"},
    speed:      {:float, 0.1},
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
    {:sync_stance, {:every, 300}},
    {:sync_all, {:every, 3000}},
    {:sync_all, {:upon, Character, :move}},
    {:sync_all_detailed, {:upon, Character, :create}},
    {:sync_drop, {:upon, Character, :drop}},
    {:sync_projectiles, {:upon, Projectile, :sync}}
  ]
  touches [
    {Projectile, :box, {:x, :y, :height, :width}}
  ]

  def move(event, params) do
    char = event.this
    move_char(char, params)
    bubble(event, :move)
  end

  def move_char(char, {x_delta, y_delta}) do
    speed = attr(char, :speed)
    direction = attr(char, :direction)

    if (x_delta < 0) do
      set(char, :direction, "left")
      mutate(char, :x, -speed, @move_transform)
    end
    if (x_delta > 0) do
      set(char, :direction, "right")
      mutate(char, :x, speed, @move_transform)
    end
    if (y_delta < 0) do
      set(char, :direction, "up")
      mutate(char, :y, -speed, @move_transform)
    end
    if (y_delta > 0) do
      set(char, :direction, "down")
      mutate(char, :y, speed, @move_transform)
    end
    set(char, :stance, 1)
  end

  def touches(event, {Projectile, projectile}) do
  end

  def stop(event, params) do
    stop_char(event.this, params)
    bubble(event, :move)
  end

  def stop_char(char, {x_delta, y_delta}) do
    if (x_delta != 0), do: mutate(char, :x, 0, @move_transform)
    if (y_delta != 0), do: mutate(char, :y, 0, @move_transform)
    if (x_delta != 0 && y_delta != 0), do: set(char, :stance, 0)
  end

  def sync_all(event, params), do: sync_all(event)
  def sync_all(event) do
    packet = sync(event, Character, [:name, :x, :y, :direction, :stance])
    tell(event.this, packet)
  end

  def sync_all_detailed(event, params), do: sync_all(event)
  def sync_all_detailed(event) do
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

  def sync_stance(event, params), do: sync_stance(event)
  def sync_stance(event) do
    packet = sync(event, Character, [:name, :x, :y, :stance])
    tell(event.this, packet)
  end

  def sync_projectiles(event, {packet}) do
    tell(event.this, packet)
  end
end
