defmodule Moongate.CoreTime do
  import Moongate.CoreMath

  def convert({d, unit_a}, unit_b) do
    convert_duration({d, normalize_unit(unit_a)}, normalize_unit(unit_b))
  end

  defp convert_duration({d, :second}, :hour), do: divide(d, 3600)
  defp convert_duration({d, :second}, :minute), do: divide(d, 60)
  defp convert_duration({d, :second}, :second), do: d
  defp convert_duration({d, :second}, :millisecond), do: multiply(d, 1_000)
  defp convert_duration({d, :second}, :microsecond), do: multiply(d, 1_000_000)
  defp convert_duration({d, :second}, :nanosecond), do: multiply(d, 1_000_000_000)

  defp convert_duration({d, :millisecond}, :hour), do: multiply(d, 0.001) |> divide(3600)
  defp convert_duration({d, :millisecond}, :minute), do: multiply(d, 0.001) |> divide(60)
  defp convert_duration({d, :millisecond}, :second), do: multiply(d, 0.001)
  defp convert_duration({d, :millisecond}, :millisecond), do: d
  defp convert_duration({d, :millisecond}, :microsecond), do: multiply(d, 1_000)
  defp convert_duration({d, :millisecond}, :nanosecond), do: multiply(d, 1_000_000)

  defp convert_duration({d, :microsecond}, :hour), do: multiply(d, 0.000001) |> divide(3600)
  defp convert_duration({d, :microsecond}, :minute), do: multiply(d, 0.000001) |> divide(60)
  defp convert_duration({d, :microsecond}, :second), do: multiply(d, 0.000001)
  defp convert_duration({d, :microsecond}, :millisecond), do: multiply(d, 0.001)
  defp convert_duration({d, :microsecond}, :microsecond), do: d
  defp convert_duration({d, :microsecond}, :nanosecond), do: multiply(d, 1_000)

  defp convert_duration({d, :nanosecond}, :hour), do: multiply(d, 0.000000001) |> divide(3600)
  defp convert_duration({d, :nanosecond}, :minute), do: multiply(d, 0.000000001) |> divide(60)
  defp convert_duration({d, :nanosecond}, :second), do: multiply(d, 0.000000001)
  defp convert_duration({d, :nanosecond}, :millisecond), do: multiply(d, 0.000001)
  defp convert_duration({d, :nanosecond}, :microsecond), do: multiply(d, 0.001)
  defp convert_duration({d, :nanosecond}, :nanosecond), do: d

  defp normalize_unit(:hours), do: :hour
  defp normalize_unit(:minutes), do: :minute
  defp normalize_unit(:seconds), do: :second
  defp normalize_unit(:milliseconds), do: :millisecond
  defp normalize_unit(:microseconds), do: :microsecond
  defp normalize_unit(:nanoseconds), do: :nanosecond
  defp normalize_unit(unit), do: unit
end
