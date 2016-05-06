defmodule Moongate.Supervisor do
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, [name: :supervisor])
  end

  @doc """
    Prepare the supervision tree.
  """
  def init(config) do
    [
      worker(Moongate.Registry.GenServer, [], [id: :registry]),
      worker(Moongate.Repo, [], [id: :repo]),
      worker(Moongate.Auth.GenServer, [config], [id: :auth]),
      supervisor(Moongate.Event.Supervisor, [], [id: :event]),
      supervisor(Moongate.Pool.Supervisor, [], [id: :pool]),
      supervisor(Moongate.Stage.Supervisor, [], [id: :stage]),
      supervisor(Moongate.Socket.TCP.Supervisor, [], [id: :tcp]),
      supervisor(Moongate.Socket.UDP.Supervisor, [], [id: :udp]),
      supervisor(Moongate.Socket.Web.Supervisor, [], [id: :ws]),
      supervisor(Moongate.HTTP.Supervisor, [], [id: :http])
    ]
    |> supervise(strategy: :one_for_one)
  end
end
