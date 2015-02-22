defmodule Generators.GreenAcres do
  use Mixins.Random

  def init(params) do
    seed_random
    green_acres(params["width"], params["height"])
  end

  defp green_acres(width, height) do
    0..width * height |> Enum.map(
      &%{
        id: UUID.uuid4(:hex),
        tile: random_tile,
        x: trunc(rem(&1, width)),
        y: trunc(div(&1, height))}
      )
  end

  defp random_tile do
    "grass_0#{random_of(4)}"
  end
end
