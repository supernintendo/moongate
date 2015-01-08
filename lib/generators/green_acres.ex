defmodule Generators.GreenAcres do
  def init(params) do
    green_acres(params["width"], params["height"])
  end

  defp green_acres(width, height) do
    0..width * height |> Enum.map(
      &%{
        x: trunc(rem(&1, width)),
        y: trunc(div(&1, height))}
      )
  end
end
