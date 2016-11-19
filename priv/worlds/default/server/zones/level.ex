defmodule Default.Zone.Level do
  import Moongate.Zones

  rings [Player]

  @doc """
    This is called when a player joins this
    zone.
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
    zone.
  """
  def departure(client), do: client |> depart
end
