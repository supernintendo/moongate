defmodule Default.Zone.Level do
  use Moongate.DSL, :zone

  rings [Player]

  def client_joined(event) do
    event
    |> push_state({:origin_id, &(&1.id)})
    |> subscribe(Player)
  end

  def client_left(event), do: event
end
