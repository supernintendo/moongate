defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Character, Tile]
  takes :move, :player_move, {:int, :int}
  takes :stop, :player_stop, {:int, :int}

  def arrival(event) do
    new event, Character, [origin: event.origin]
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
