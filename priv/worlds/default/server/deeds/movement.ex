defmodule Default.Deed.Movement do
  import Moongate.Deeds

  attributes %{
    x: :float,
    y: :float
  }

  def move(entity, {x, y}) do
    entity
    |> set(:x, x)
    |> set(:y, y)
  end
end
