defmodule Moongate.CoreTypesTest do
  use ExUnit.Case
  alias Moongate.CoreTypes

  test "&cast/2 into boolean" do
    assert CoreTypes.cast(1, Boolean) == true
    assert CoreTypes.cast(1.0, Boolean) == true
    assert CoreTypes.cast("t", Boolean) == true
    assert CoreTypes.cast("true", Boolean) == true
    assert CoreTypes.cast(0, Boolean) == false
    assert CoreTypes.cast(0.0, Boolean) == false
    assert CoreTypes.cast("f", Boolean) == false
    assert CoreTypes.cast("false", Boolean) == false
  end

  test "&cast/2 into integer" do
    assert CoreTypes.cast(8, Integer) == 8
    assert CoreTypes.cast(15.75, Integer) == 16
    assert CoreTypes.cast(32.25, Integer) == 32
    assert CoreTypes.cast(64.25, Integer, :round_down) == 64
    assert CoreTypes.cast(127.75, Integer, :round_up) == 128
    assert CoreTypes.cast("256", Integer) == 256
    assert CoreTypes.cast("512.0", Integer) == 512
    assert CoreTypes.cast(true, Integer) == 1
    assert CoreTypes.cast(false, Integer) == 0
  end

  test "&cast/2 into float" do
    assert CoreTypes.cast(8, Float) == 8.0
    assert CoreTypes.cast(16, Float) == 16.0
    assert CoreTypes.cast("32", Float) == 32.0
    assert CoreTypes.cast("6.4", Float) == 6.4
    assert CoreTypes.cast(true, Float) == 1.0
    assert CoreTypes.cast(false, Float) == 0.0
  end

  test "&cast/2 into string" do
    assert CoreTypes.cast("Hello World", String) == "Hello World"
    assert CoreTypes.cast(8, String) == "8"
    assert CoreTypes.cast(16.0, String) == "16.0"
    assert CoreTypes.cast(:test, String) == "test"
    assert CoreTypes.cast(Moongate.CoreTypesTest, String) == "Moongate.CoreTypesTest"
    assert CoreTypes.cast(nil, String) == ""
    assert CoreTypes.cast(%{"hello" => "world"}, String) == "%{\"hello\" => \"world\"}"
    assert CoreTypes.cast([0, 1, 2, 3, 4], String) == "[0, 1, 2, 3, 4]"
    assert CoreTypes.cast({:noreply, %{}}, String) == "{:noreply, %{}}"
  end
end
