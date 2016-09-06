defmodule Default.Stage.Level do
  import Moongate.Stages

  pools [Player]

  @doc """
    This is called when a player joins this
    stage.
  """
  def arrival(client) do
    client
    |> subscribe(Player)
    |> create(Player, %{
      x: random(1028),
      y: random(1028)
    })
  end

  @doc """
    This is called when a player leaves this
    stage.
  """
  def departure(client), do: client |> depart
end
