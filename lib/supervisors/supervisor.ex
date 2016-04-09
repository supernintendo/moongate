defmodule Moongate.Supervisor do
  use Supervisor

  def start_link({world_supervisors}) do
    Supervisor.start_link(__MODULE__, {world_supervisors, %{}}, [name: :supervisor])
  end

  def start_link({world_supervisors, config}) do
    Supervisor.start_link(__MODULE__, {world_supervisors, config}, [name: :supervisor])
  end

  @doc """
    Prepare the supervision tree.
  """
  def init({world_supervisors, config}) do
    [
      worker(Moongate.SupervisionTree, [], [id: :tree]),
      worker(Moongate.Repo, [], [id: :repo]),
      worker(Moongate.Auth, [config], [id: :auth]),
      supervisor(Moongate.Events.Supervisor, [], [id: :events]),
      supervisor(Moongate.Pools.Supervisor, [], [id: :pool]),
      supervisor(Moongate.Stages.Supervisor, [], [id: :stages]),
      supervisor(Moongate.Sockets.TCP.Supervisor, [], [id: :tcp_sockets]),
      supervisor(Moongate.Sockets.UDP.Supervisor, [], [id: :udp_sockets]),
      supervisor(Moongate.Sockets.Web.Supervisor, [], [id: :web_sockets]),
      supervisor(Moongate.Sockets.HTTP.Supervisor, [], [id: :http_hosts])
    ]
    ++ supervisors_from(world_supervisors)
    |>supervise(strategy: :one_for_one)
  end

  def supervisors_from(world_supervisors) do
    world_supervisors |> Enum.map(&supervisor_from(&1))
  end

  def supervisor_from({id, params}) do
    [params["module"]]
    |> Module.safe_concat
    |> supervisor([], [id: String.to_atom(id)])
  end
end
