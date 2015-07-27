defmodule Moongate.Supervisor do
  use Supervisor

  def start_link(world_supervisors) do
    Supervisor.start_link(__MODULE__, world_supervisors)
  end

  @doc """
    Prepare the supervision tree.
  """
  def init(world_supervisors) do
    children = [
      worker(SupervisionTree, [], [id: :tree]),
      worker(Db.Repo, [], [id: :repo]),
      worker(Auth, [], [id: :auth]),
      supervisor(Events.Supervisor, [], [id: :events]),
      supervisor(Sockets.TCP.Supervisor, [], [id: :tcp_sockets]),
      supervisor(Sockets.UDP.Supervisor, [], [id: :udp_sockets])
    ] ++ supervisors_from(world_supervisors)
    supervise(children, strategy: :one_for_one)
  end

  def supervisors_from(world_supervisors) do
    world_supervisors |> Enum.map(&supervisor_from(&1))
  end

  def supervisor_from({id, params}) do
    supervisor(Module.safe_concat([params["module"]]), [], [id: id])
  end
end
