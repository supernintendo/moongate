defmodule Default.Pools.Tiles do
  import Moongate.Pool

  aspects %{
    x: :integer,
    y: :integer,
    color: :string
  }

  # index_by {[:x, :y], "_"}
end