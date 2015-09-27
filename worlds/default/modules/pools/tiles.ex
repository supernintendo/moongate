defmodule Default.Pools.Tile do
  import Moongate.Pool

  attributes %{
    x: :integer,
    y: :integer,
    color: :string
  }
  triggers [
    {:refresh, {:in_response_to, Character, [:init, :move]}},
    {:refresh, {:every, 3000}}
  ]

  def is_blocked(x, y) do
    false
  end

  def refresh(e) do
  end
end
