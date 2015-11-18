defmodule Default.Pools.Character do
  import Moongate.Pool

  @move_transform %{
    mode: "linear",
    tag: "movement"
  }
  @standing 0
  @walking 1
  @attacking 2

  attributes %{
    name:         {:string, "a noob"},
    speed:        {:float, 0.125},
    height:       {:int, 24},
    width:        {:int, 24},
    x:            {:float, 50.0},
    y:            {:float, 50.0},
    direction:    {:string, "up"},
    stance:       {:int, @standing},

    archetype:    {:string, "elf"},
    attack:       {:int, 0},
    attack_delay: {:int, 100},
    dead:         {:int, 0},
    defense:      {:int, 0},
    health:       {:int, 3},
    max_health:   {:int, 3},
    rupees:       {:int, 0}
  }
  cascades [
    {:sync_movement, {:every, 500}},
    {:sync_all, {:upon, Character, :sync}},
    {:check_if_hurt, {:upon, Character, :attack}},
    {:reset_stance, {:upon, Character, :reset_stance}},
    {:sync_initial, {:upon, Character, :create}},
    {:sync_drop, {:upon, Character, :drop}},
    {:sync_other, {:upon, Pickup, :sync}},
    {:sync_other, {:upon, Particle, :sync}}
  ]
  touches []

  def move(event, params) do
    char = event.this
    speed = attr(char, :speed)
    stance = attr(char, :stance)

    if stance != @attacking do
      set_direction(char, params)
      start_moving(char, params, speed)
      set(char, :stance, @walking)
      bubble(event, :sync)
    end
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
    stance = attr(event.this, :stance)

    if stance != @attacking do
      stop_moving(event.this, params)
      bubble(event, :sync)
    end
  end

  def stop_moving(char, {x_delta, y_delta}) do
    if (x_delta != 0), do: mutate(char, :x, 0, @move_transform)
    if (y_delta != 0), do: mutate(char, :y, 0, @move_transform)
    if (x_delta != 0 && y_delta != 0), edo: set(char, :stance, @standing)
  end

  def attack(event) do
    char = event.this
    archetype = attr(char, :archetype)
    dead = attr(char, :dead)
    delay = attr(char, :attack_delay)

    unless dead == 1 do
      stop(event, {1, 1})
      set(char, :stance, @attacking)
      echo_after(delay, event, {:reset_stance})
      attack = attack_for(archetype, char)
      bubble(event, :attack, attack)
      add_particle(event, attack)
    end
  end

  def reset_stance(event) do
    char = event.this
    set(char, :stance, @standing)
  end

  def attack_for("elf", char) do
    id = attr(char, :origin).id
    {x, y, w, h, d} = positional_attributes(char)

    case d do
      "up" -> {id, x, y - 16, 32, 32, "slash", d}
      "down" -> {id, x, y + h + 2, 32, 32, "slash", d}
      "left" -> {id, x - 34, y, 32, 32, "slash", d}
      "right" -> {id, x + w + 2, y, 32, 32, "slash", d}
    end
  end

  def attack_for("mage", char) do
    id = attr(char, :origin).id
    {x, y, w, h, d} = positional_attributes(char)

    case d do
      "up" -> {id, d, x + 6, y - 48, 20, 20, "sparkles"}
      "down" -> {id, d, x + 6, y + h + 12, 20, 20, "sparkles"}
      "left" -> {id, d, x - 48, y + 6, 20, 20, "sparkles"}
      "right" -> {id, d, x + w + 12, y + 6, 20, 20, "sparkles"}
    end
  end

  def attack_for("skeleton", char) do
    IO.puts "TODO"
  end

  def add_particle(event, attack) do
    case attack do
      {a_id, a_x, a_y, a_w, a_h, "slash"} ->
        echo(event, {:add_particle, {a_x, a_y, "slash", 400}})
      {a_id, a_x, a_y, a_w, a_h, "slash", a_d} ->
        echo(event, {:add_particle, {a_x, a_y, "slash", 400, a_d}})
      _ -> nil
    end
  end

  def check_if_hurt(event, attack) do
    char = event.this

    if hit?(char, attack) do
      health = attr(char, :health)

      if health > 1 do
        set(char, :health, health - 1)
      else
        set(char, :health, 0)
        set(char, :dead, 1)
      end
    end
  end

  def hit?(char, {a_id, a_x, a_y, a_w, a_h, a_type}) do
    hit?(char, {a_id, a_x, a_y, a_w, a_h, a_type, "default"})
  end

  def hit?(char, {a_id, a_x, a_y, a_w, a_h, _a_type, _a_direction}) do
    id = attr(char, :origin).id
    {x, y, w, h, d} = positional_attributes(char)

    id != a_id &&
      x < a_x + a_w &&
      x + w > a_x &&
      y < a_y + a_h &&
      y + h > a_y
  end

  def positional_attributes(char) do
    direction = attr(char, :direction)
    x = attr(char, :x)
    y = attr(char, :y)
    width = attr(char, :width)
    height = attr(char, :height)

    {x, y, width, height, direction}
  end

  # Sync

  def sync_movement(event, params), do: sync_movement(event)
  def sync_movement(event) do
    if attr(event.this, :stance) == @walking do
      bubble(event, :sync)
    end
  end

  def sync_all(event, params), do: sync_all(event)
  def sync_all(event) do
    packet = sync(event, Character, [:name, :x, :y, :direction, :stance, :health])
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

  def sync_other(event, {packet}) do
    tell(event.this, packet)
  end
end
