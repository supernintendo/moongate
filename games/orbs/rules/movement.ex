defmodule Orbs.Movement do
  use Moongate.DSL, :rule

  describe do
    %{
      speed: Integer,
      x: Integer,
      y: Integer
    }
  end

  handle "call", ev do
    move(ev)
  end

  defp move(%{arguments: {x, y}} = ev) do
    ev
    |> select(ev.origin)
    |> set(%{
      x: x,
      y: y
    })
  end
  defp move(ev), do: ev
end
