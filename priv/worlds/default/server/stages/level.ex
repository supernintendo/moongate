defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Player]

  def arrival(event) do
    subscribe(event.origin, Player)
    new(event, Player, [
      origin: event.origin,
      x: random(128),
      y: random(128)
    ])
  end

  def departure(event) do
    player = first Player, [origin: event.origin]
    drop(event, player)
  end
end
