defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Character]

  def joined(e) do
    new Character, [origin: e.origin]
    :ok
  end

  def player_move(e) do
    :ok
  end
end
