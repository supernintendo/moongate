defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Character, Tile]
  takes :move, :player_move, {:int, :int}

  def joined(event) do
    new event, Character, [origin: event.origin]
    :ok
  end

  def player_move(event, params) do
    player = first Character, [origin: event.origin]
    cast event, player, :move, params
    :ok
  end
end
