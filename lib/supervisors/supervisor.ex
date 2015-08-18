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
      worker(Moongate.SupervisionTree, [], [id: :tree]),
      worker(Moongate.Db.Repo, [], [id: :repo]),
      worker(Moongate.Auth, [], [id: :auth]),
      supervisor(Moongate.Events.Supervisor, [], [id: :events]),
      supervisor(Moongate.Pools.Supervisor, [], [id: :pools]),
      supervisor(Moongate.Stages.Supervisor, [], [id: :stages]),
      supervisor(Moongate.Sockets.TCP.Supervisor, [], [id: :tcp_sockets]),
      supervisor(Moongate.Sockets.UDP.Supervisor, [], [id: :udp_sockets]),
      supervisor(Moongate.Sockets.Web.Supervisor, [], [id: :web_sockets]),
      supervisor(Moongate.Sockets.HTTP.Supervisor, [], [id: :http_hosts])
    ] ++ supervisors_from(world_supervisors)
    supervise(children, strategy: :one_for_one)
  end

  def supervisors_from(world_supervisors) do
    world_supervisors |> Enum.map(&supervisor_from(&1))
  end

  def supervisor_from({id, params}) do
    supervisor(Module.safe_concat([params["module"]]), [], [id: String.to_atom(id)])
  end
end
