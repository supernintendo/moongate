defmodule Default.Stage.Level do
  import Moongate.Stage

  pools [Player]

  @doc """
    This is called when a player joins this
    stage.
  """
  def arrival(client) do
    attributes = %{
      x: random(1028),
      y: random(1028)
    }
    client
    |> subscribe(Player)
    |> create(Player, attributes)
  end

  @doc """
    This is called when a player leaves this
    stage.
  """
  def departure(client) do
    client
    |> depart
  end
end
