defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Character, Event, Pickup, Projectile]
  takes :move, :player_move, {:int, :int}
  takes :stop, :player_stop, {:int, :int}

  def arrival(event) do
    new(event, Character, [
      origin: event.origin,
      archetype: random_from({"elf", "mage", "skeleton"}),
      x: random(640),
      y: random(512)
    ])
    new(event, Event, [])
  end

  def departure(event) do
    player = first Character, [origin: event.origin]
    drop(event, player)
  end

  def echo(event, Event, {:place_rupee}) do
    new(event, Pickup, [
      item: random_from({"green_rupee", "blue_rupee", "red_rupee"}),
      x: random(640),
      y: random(512)
    ])
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
