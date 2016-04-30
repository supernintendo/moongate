defmodule Default.Deeds.Test do
  import Moongate.Deed

  attributes %{}

  def foo(entity) do
    entity
    |> announce(:foo)
  end

  def announced({Player, :foo}, entity) do
    entity
  end
end
