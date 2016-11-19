defmodule Moongate.Supervisor do
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, [name: :supervisor])
  end

  @doc """
    Prepare the supervision tree.
  """
  def init(_config) do
    [
      worker(Moongate.Registry.GenServer, [], [id: :registry]),
      worker(Moongate.Logger.GenServer, [], [id: :logger]),
      supervisor(Moongate.Fiber.Supervisor, [], [id: :fiber]),
      supervisor(Moongate.Ring.Supervisor, [], [id: :ring]),
      supervisor(Moongate.Session.Supervisor, [], [id: :session]),
      supervisor(Moongate.Zone.Supervisor, [], [id: :zone]),
      supervisor(Moongate.TCP.Supervisor, [], [id: :tcp]),
      supervisor(Moongate.UDP.Supervisor, [], [id: :udp]),
      supervisor(Moongate.WebSocket.Supervisor, [], [id: :ws]),
      supervisor(Moongate.HTTP.Supervisor, [], [id: :http])
    ]
    |> supervise(strategy: :one_for_one)
  end
end
