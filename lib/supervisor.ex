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
      worker(Moongate.Registry.GenServer, [], [id: :registry]),
      worker(Moongate.Repo, [], [id: :repo]),
      worker(Moongate.Auth.GenServer, [config], [id: :auth]),
      supervisor(Moongate.Dispatcher.Supervisor, [], [id: :dispatcher]),
      supervisor(Moongate.Event.Supervisor, [], [id: :event]),
      supervisor(Moongate.Pool.Supervisor, [], [id: :pool]),
      supervisor(Moongate.Stage.Supervisor, [], [id: :stage]),
      supervisor(Moongate.Socket.TCP.Supervisor, [], [id: :tcp]),
      supervisor(Moongate.Socket.UDP.Supervisor, [], [id: :udp]),
      supervisor(Moongate.Socket.Web.Supervisor, [], [id: :ws]),
      supervisor(Moongate.HTTP.Supervisor, [], [id: :http])
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
