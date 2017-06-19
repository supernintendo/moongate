defmodule Moongate.CoreTimeTest do
  use ExUnit.Case
  alias Moongate.CoreTime

  test "&convert/2 with seconds" do
    assert CoreTime.convert({3_600, :second}, :hour) == 1.0
    assert CoreTime.convert({60, :second}, :minute) == 1.0
    assert CoreTime.convert({2, :second}, :second) == 2.0
    assert CoreTime.convert({0.003, :second}, :millisecond) == 3.0
    assert CoreTime.convert({5.0e-6, :second}, :microsecond) == 5.0
    assert CoreTime.convert({8.0e-9, :second}, :nanosecond) == 8.0
  end

  test "&convert/2 with milliseconds" do
    assert CoreTime.convert({4.68e+7, :millisecond}, :hour) == 13.0
    assert CoreTime.convert({1.26e+6, :millisecond}, :minute) == 21.0
    assert CoreTime.convert({34000, :millisecond}, :second) == 34.0
    assert CoreTime.convert({55, :millisecond}, :millisecond) == 55.0
    assert CoreTime.convert({0.089, :millisecond}, :microsecond) == 89.0
    assert CoreTime.convert({0.000144, :millisecond}, :nanosecond) == 144.0
  end

  test "&convert/2 with microseconds" do
    assert CoreTime.convert({8.388e+11, :microsecond}, :hour) == 233.0
    assert CoreTime.convert({2.262e+10, :microsecond}, :minute) == 377.0
    assert CoreTime.convert({6.1e+8, :microsecond}, :second) == 610.0
    assert CoreTime.convert({987_000, :microsecond}, :millisecond) == 987.0
    assert CoreTime.convert({1_597, :microsecond}, :microsecond) == 1_597.0
    assert CoreTime.convert({2.584, :microsecond}, :nanosecond) == 2_584.0
  end

  test "&convert/2 with nanoseconds" do
    assert CoreTime.convert({1.50516e+16, :nanosecond}, :hour) == 4_181.000000000001
    assert CoreTime.convert({4.059e+14, :nanosecond}, :minute) == 6_765.0
    assert CoreTime.convert({1.0946e+13, :nanosecond}, :second) == 10_946.0
    assert CoreTime.convert({1.7711e+10, :nanosecond}, :millisecond) == 17_711.0
    assert CoreTime.convert({28_657_000, :nanosecond}, :microsecond) == 28_657.0
    assert CoreTime.convert({46_368, :nanosecond}, :nanosecond) == 46_368.0
  end
end
