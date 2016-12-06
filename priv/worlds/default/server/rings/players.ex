defmodule Default.Ring.Player do
  use Moongate.DSL, :ring

  attributes %{
    origin: :origin,
    drift: :integer,
    speed: :integer,
    x: :integer,
    y: :integer
  }
  deeds [XY]
  public [:origin, :drift, :speed, :x, :y]

  def client_subscribed(event) do
    params = %{
      origin: event.origin,
      drift: 2 + :rand.uniform(6),
      speed: 256 + :rand.uniform(512),
      x: :rand.uniform(512),
      y: :rand.uniform(512)
    }

    event
    |> create(params)
  end

  def client_unsubscribed(event) do
    # IO.inspect find_by(event, :origin, event.origin)

    event
    # |> drop(find_by(event, :origin, event.origin))
  end
end
