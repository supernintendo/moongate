defmodule Default.Deed.XY do
  use Moongate.DSL, :deed

  attributes %{
    x: :float,
    y: :float
  }

  def call({x, y}, event) do
    event
    |> target(&(&1.origin.id == event.origin.id))
    |> set(%{x: x, y: y})
  end
end
