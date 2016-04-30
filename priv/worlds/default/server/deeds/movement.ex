defmodule Default.Deeds.Movement do
  import Moongate.Deed

  attributes %{
    direction: :string,
    speed: :float,
    x: :float,
    y: :float
  }

  def move(entity, {x, y}) do
    entity
    |> set_direction(x, y)
    |> start_moving(x, y)
  end

  def stop(entity, {x, y}) do
    entity
    |> stop_moving(x, y)
  end

  defp start_moving(entity, x, y) do
    speed = entity |> get(:speed)

    cond do
      x < 0 -> entity |> lin(:x, :movement, speed * -1)
      y < 0 -> entity |> lin(:y, :movement, speed * -1)
      x > 0 -> entity |> lin(:x, :movement, speed)
      y > 0 -> entity |> lin(:y, :movement, speed)
      true -> entity
    end
  end

  defp stop_moving(entity, x, y) do
    cond do
      x != 0 and y != 0 ->
        entity
        |> lin(:x, :movement, 0)
        |> lin(:y, :movement, 0)
      x != 0 -> entity |> lin(:x, :movement, 0)
      y != 0 -> entity |> lin(:y, :movement, 0)
      true -> entity
    end
  end

  defp set_direction(entity, x, y) do
    cond do
      x < 0 -> entity |> set(:direction, "left")
      y < 0 -> entity |> set(:direction, "up")
      x > 0 -> entity |> set(:direction, "right")
      y > 0 -> entity |> set(:direction, "down")
      true -> entity
    end
  end
end
