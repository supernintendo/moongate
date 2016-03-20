defmodule Default.Deeds.Movement do
  import Moongate.Deed

  attributes %{
    direction: :string,
    speed: :float,
    x: :float,
    y: :float
  }
  def move(this, {x, y}, _event) do
    this |> set_direction(x, y)
    this |> start_moving(x, y)
  end

  def stop(this, {x, y}, _event) do
    this |> stop_moving(x, y)
  end

  defp start_moving(char, x, y) do
    speed = attr char, :speed

    cond do
      x < 0 -> char |> mutate(:x, -speed, transform)
      y < 0 -> char |> mutate(:y, -speed, transform)
      x > 0 -> char |> mutate(:x, speed, transform)
      y > 0 -> char |> mutate(:y, speed, transform)
    end
  end

  defp stop_moving(char, x, y) do
    if (x != 0), do: char |> mutate(:x, 0, transform)
    if (y != 0), do: char |> mutate(:y, 0, transform)
  end

  defp set_direction(char, x, y) do
    cond do
      x < 0 -> char |> set(:direction, "left")
      y < 0 -> char |> set(:direction, "up")
      x > 0 -> char |> set(:direction, "right")
      y > 0 -> char |> set(:direction, "down")
    end
  end

  defp transform do
    %{
      mode: "linear",
      tag: "movement"
    }
  end
end
