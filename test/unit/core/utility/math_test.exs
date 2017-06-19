defmodule Moongate.CoreMathTest do
  use ExUnit.Case
  alias Moongate.CoreMath

  test "&add/2" do
    assert CoreMath.add(28, 14) == 42
    assert CoreMath.add(8, -19) == -11
    assert CoreMath.add(25, -50) == -25
    assert CoreMath.add(10, 0) == 10
  end

  test "&subtract/2" do
    assert CoreMath.subtract(64, 22) == 42
    assert CoreMath.subtract(8, 19) == -11
    assert CoreMath.subtract(25, 50) == -25
    assert CoreMath.subtract(10, 0) == 10
  end

  test "&multiply/2" do
    assert CoreMath.multiply(21, 2) == 42
    assert CoreMath.multiply(11, -1) == -11
    assert CoreMath.multiply(10, 0) == 0
  end

  test "&divide/2" do
    assert CoreMath.divide(84, 2) == 42
    assert CoreMath.divide(44, -4) == -11
    assert_raise ArgumentError, fn ->
      CoreMath.divide(10, 0)
    end
  end
end
