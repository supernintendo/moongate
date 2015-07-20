defmodule Moongate.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @doc """
    Prepare the supervision tree.
  """
  def init(nil) do
    children = [
      worker(SupervisionTree, [], [id: :tree]),
      worker(Db.Repo, [], [id: :repo]),
      worker(Auth, [], [id: :auth]),
      supervisor(Areas.Supervisor, [], [id: :areas]),
      supervisor(Entity.Supervisor, [], [id: :entity]),
      supervisor(Events.Supervisor, [], [id: :events]),
      supervisor(Sessions.Supervisor, [], [id: :sessions]),
      supervisor(Sockets.TCPSupervisor, [], [id: :tcp_sockets]),
      supervisor(Sockets.UDPSupervisor, [], [id: :udp_sockets])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
