defmodule Default.Deeds.Movement do
  import Moongate.Deed

  attributes %{
    direction: :string,
    speed: :float,
    x: :float,
    y: :float
  }
  def move(this, {x, y}, event) do
    set_direction this, x, y
    start_moving this, x, y
  end

  def stop(this, {x, y}, event) do
    stop_moving this, x, y
  end

  defp start_moving(char, x, y) do
    speed = attr char, :speed

    cond do
      x < 0 -> mutate(char, :x, -speed, transform)
      y < 0 -> mutate(char, :y, -speed, transform)
      x > 0 -> mutate(char, :x, speed, transform)
      y > 0 -> mutate(char, :y, speed, transform)
    end
  end

  defp stop_moving(char, x, y) do
    if (x != 0), do: mutate(char, :x, 0, transform)
    if (y != 0), do: mutate(char, :y, 0, transform)
  end

  defp set_direction(char, x, y) do
    cond do
      x < 0 -> set(char, :direction, "left")
      y < 0 -> set(char, :direction, "up")
      x > 0 -> set(char, :direction, "right")
      y > 0 -> set(char, :direction, "down")
    end
  end

  defp transform do
    %{
      mode: "linear",
      tag: "movement"
    }
  end
end
