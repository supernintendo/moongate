defmodule Moongate.CoreTime do
  def convert({d, unit_a}, unit_b) do
    convert_duration({d, normalize_unit(unit_a)}, normalize_unit(unit_b))
  end

  defp convert_duration({d, :second}, :hour), do: d / 3600
  defp convert_duration({d, :second}, :minute), do: d / 60
  defp convert_duration({d, :second}, :second), do: d
  defp convert_duration({d, :second}, :millisecond), do: d * 1_000
  defp convert_duration({d, :second}, :microsecond), do: d * 1_000_000
  defp convert_duration({d, :second}, :nanosecond), do: d * 1_000_000_000

  defp convert_duration({d, :millisecond}, :hour), do: (d * 0.001) / 3600
  defp convert_duration({d, :millisecond}, :minute), do: (d * 0.001) / 60
  defp convert_duration({d, :millisecond}, :second), do: d * 0.001
  defp convert_duration({d, :millisecond}, :millisecond), do: d
  defp convert_duration({d, :millisecond}, :microsecond), do: d * 1_000
  defp convert_duration({d, :millisecond}, :nanosecond), do: d * 1_000_000

  defp convert_duration({d, :microsecond}, :hour), do: (d * 0.000001) / 3600
  defp convert_duration({d, :microsecond}, :minute), do: (d * 0.000001) / 60
  defp convert_duration({d, :microsecond}, :second), do: d * 0.000001
  defp convert_duration({d, :microsecond}, :millisecond), do: d * 0.001
  defp convert_duration({d, :microsecond}, :microsecond), do: d
  defp convert_duration({d, :microsecond}, :nanosecond), do: d * 1_000

  defp convert_duration({d, :nanosecond}, :hour), do: (d * 0.000000001) / 3600
  defp convert_duration({d, :nanosecond}, :minute), do: (d * 0.000000001) / 60
  defp convert_duration({d, :nanosecond}, :second), do: d * 0.000000001
  defp convert_duration({d, :nanosecond}, :millisecond), do: d * 0.000001
  defp convert_duration({d, :nanosecond}, :microsecond), do: d * 0.001
  defp convert_duration({d, :nanosecond}, :nanosecond), do: d

  defp normalize_unit(:h), do: :hour
  defp normalize_unit(:hr), do: :hour
  defp normalize_unit(:hrs), do: :hour
  defp normalize_unit(:hours), do: :hour
  defp normalize_unit(:m), do: :minute
  defp normalize_unit(:min), do: :minute
  defp normalize_unit(:mins), do: :minute
  defp normalize_unit(:minutes), do: :minute
  defp normalize_unit(:s), do: :second
  defp normalize_unit(:sec), do: :second
  defp normalize_unit(:secs), do: :second
  defp normalize_unit(:seconds), do: :second
  defp normalize_unit(:ms), do: :millisecond
  defp normalize_unit(:msec), do: :millisecond
  defp normalize_unit(:msecs), do: :millisecond
  defp normalize_unit(:milliseconds), do: :millisecond
  defp normalize_unit(:us), do: :microsecond
  defp normalize_unit(:usec), do: :microsecond
  defp normalize_unit(:usecs), do: :microsecond
  defp normalize_unit(:microseconds), do: :microsecond
  defp normalize_unit(:ns), do: :nanosecond
  defp normalize_unit(:nsec), do: :nanosecond
  defp normalize_unit(:nsecs), do: :nanosecond
  defp normalize_unit(:nanoseconds), do: :nanosecond
  defp normalize_unit(unit), do: unit
end
