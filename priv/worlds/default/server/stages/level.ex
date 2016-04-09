defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Player]

  def arrival(client) do
    attributes = %{
      x: random(128),
      y: random(128)
    }
    client
    |> subscribe(Player)
    |> create(Player, attributes)
  end

  def departure(client) do
    client |> depart
  end
end
