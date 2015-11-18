defmodule Default.Stage.Level do
  import Moongate.Stage

  @playable_archetypes {"elf"}
  meta %{}
  pools [Character, Event, Particle, Pickup, Projectile]
  takes :move, :player_move, {:int, :int}
  takes :stop, :player_stop, {:int, :int}
  takes :attack, :player_attack

  def arrival(event) do
    new(event, Character, [
      origin: event.origin,
      archetype: random_from(@playable_archetypes),
      x: random(640),
      y: random(512)
    ])
    new(event, Event, [])
  end

  def departure(event) do
    player = first Character, [origin: event.origin]
    drop(event, player)
  end

  def echo(event, Character, {:add_particle, {x, y, type, lifespan}}) do
    echo(event, Character, {:add_particle, {x, y, type, lifespan, "default"}})
  end
  def echo(event, Character, {:add_particle, {x, y, type, lifespan, d}}) do
    new(event, Particle, [
      direction: d,
      lifespan: 400,
      type: type,
      x: x,
      y: y
    ])
  end

  def echo(event, Character, {:reset_stance}) do
    cast(event, event.this, :reset_stance)
  end

  def echo(event, Particle, {:drop}) do
    drop(event, event.this)
  end

  def player_attack(event, params) do
    player = first Character, [origin: event.origin]
    cast(event, player, :attack)
  end

  def player_move(event, params) do
    player = first Character, [origin: event.origin]
    cast(event, player, :move, params)
  end

  def player_stop(event, params) do
    player = first Character, [origin: event.origin]
    cast(event, player, :stop, params)
  end
end
