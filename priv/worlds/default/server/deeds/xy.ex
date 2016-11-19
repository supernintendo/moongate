defmodule Default.Deed.XY do
  import Moongate.Deeds

  attributes %{
    x: :float,
    y: :float
  }

  def call(entity, {x, y}) do
    entity
    |> set(:x, x)
    |> set(:y, y)
  end
end
