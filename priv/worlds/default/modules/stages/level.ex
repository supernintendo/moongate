defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Character, Projectile]
  takes :move, :player_move, {:int, :int}
  takes :stop, :player_stop, {:int, :int}

  def arrival(event) do
    x = :random.uniform(640)
    y = :random.uniform(512)
    new event, Character, [origin: event.origin, x: x, y: y]
    new event, Projectile, [x: :random.uniform(640), y: :random.uniform(512)]
  end

  def departure(event) do
    player = first Character, [origin: event.origin]
    drop event, player
  end

  def player_move(event, params) do
    player = first Character, [origin: event.origin]
    cast event, player, :move, params
  end

  def player_stop(event, params) do
    player = first Character, [origin: event.origin]
    cast event, player, :stop, params
  end
end
