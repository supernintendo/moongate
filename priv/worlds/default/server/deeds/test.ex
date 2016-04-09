defmodule Default.Deeds.Test do
  import Moongate.Deed

  attributes %{}

  def foo(this) do
    this
    |> announce(:foo)
  end

  def announced({Player, :foo}, this) do
    this
  end
end
