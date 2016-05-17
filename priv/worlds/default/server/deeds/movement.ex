defmodule Default.Deed.Movement do
  import Moongate.Deed

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
