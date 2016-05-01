defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools [Player, Message]

  @doc """
    This is called when a player joins this
    stage.
  """
  def arrival(client) do
    attributes = %{
      x: random(128),
      y: random(128)
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
    client |> depart
  end
end
