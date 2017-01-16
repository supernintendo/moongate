defmodule Test.Ring.TestRing do
  use Moongate.DSL, :ring

  attributes %{
    origin: :origin,
    test_attr: :float
  }
  deeds [TestDeed]
  public [:origin, :test_attr]

  def client_subscribed(event) do
    event
  end

  def client_unsubscribed(event) do
    event
  end
end
