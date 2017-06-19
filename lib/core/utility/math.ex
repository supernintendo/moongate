defmodule Moongate.CoreMath do
  alias Moongate.NativeModules.Math

  def add(a, b) do
    {:ok, result} = Math.add(a * 1.0, b * 1.0)
    result
  end
  def subtract(a, b) do
    {:ok, result} = Math.subtract(a * 1.0, b * 1.0)
    result
  end
  def multiply(a, b) do
    {:ok, result} = Math.multiply(a * 1.0, b  * 1.0)
    result
  end
  def divide(a, b) do
    {:ok, result} = Math.divide(a * 1.0, b * 1.0)
    result
  end
end
