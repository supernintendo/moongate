defmodule Default.Pools.Event do
  import Moongate.Pool

  attributes %{}
  cascades []
  touches []

  def place_rupee(event, params), do: place_rupee(event)
  def place_rupee(event) do
    echo(event, {:place_rupee})
  end
end
