defmodule Test.Zone.TestZone do
  use Moongate.DSL, :zone

  rings [TestRing]

  def client_joined(event) do
    event
    |> subscribe(TestRing)
  end

  def client_left(event), do: event
end
