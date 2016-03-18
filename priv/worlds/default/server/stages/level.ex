defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Player]

  def arrival(event) do
    new(event, Player, [
      origin: event.origin,
      x: random(128),
      y: random(128)
    ])
    subscribe(event.origin, Player)
  end

  def departure(event) do
    player = first Player, [origin: event.origin]
    drop(event, player)
  end
end
