defmodule Default.Deeds.Movement do
  import Moongate.Deed

  attributes %{
    direction: :string,
    speed: :float,
    x: :float,
    y: :float
  }

  def move(this, {x, y}) do
    this
    |> set_direction(x, y)
    |> start_moving(x, y)
  end

  def stop(this, {x, y}) do
    this
    |> stop_moving(x, y)
  end

  defp start_moving(this, x, y) do
    speed = this |> get(:speed)

    cond do
      x < 0 -> this |> lin(:x, -speed)
      y < 0 -> this |> lin(:y, -speed)
      x > 0 -> this |> lin(:x, speed)
      y > 0 -> this |> lin(:y, speed)
    end
  end

  defp stop_moving(this, x, y) do
    if (x != 0), do: this |> lin(:x, 0)
    if (y != 0), do: this |> lin(:y, 0)
  end

  defp set_direction(this, x, y) do
    cond do
      x < 0 -> this |> set(:direction, "left")
      y < 0 -> this |> set(:direction, "up")
      x > 0 -> this |> set(:direction, "right")
      y > 0 -> this |> set(:direction, "down")
    end
  end
end
