defmodule Default.Deed.XY do
  use Moongate.DSL, :deed

  attributes %{
    speed: :float,
    x: :float,
    y: :float
  }

  def call({x, y}, event) do
    event
    |> target(&(&1.origin.id == event.origin.id))
    |> set(%{x: x, y: y, speed: 256 + :rand.uniform(512)})
  end
end