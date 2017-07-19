defmodule Orbs.Movement do
  use Moongate.DSL, :rule

  describe do
    %{
      x: Float,
      y: Float
    }
  end

  handle "call", ev do
    move(ev)
  end

  defp move(%{arguments: {x, y}} = ev) do
    ev
    |> select(ev.origin)
    |> set(%{
      speed: Enum.random(150..350),
      x: x,
      y: y
    })
  end
  defp move(ev), do: ev
end
