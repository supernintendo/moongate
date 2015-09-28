defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Character]

  def joined(event) do
    new Character, [origin: event.origin]
    :ok
  end

  def player_move(event) do
    :ok
  end
end
