defmodule Moongate.CoreSupervisor do
  alias Moongate.CoreConfig
  use Supervisor

  @extensions %{
    dev: Application.get_env(:moongate, :dev),
    logger: Application.get_env(:moongate, :logger)
  }

  def start_link(%CoreConfig{} = config) do
    Supervisor.start_link(__MODULE__, config, [name: :supervisor])
  end

  @doc """
  Initializes the supervision tree.
  """
  def init(%CoreConfig{} = config) do
    [
      worker(Moongate.CoreETS, [], [id: :ets]),
      worker(Moongate.CoreSupport, [], [id: :support]),
      supervisor(Moongate.CorePool, [], [id: :pool]),
      supervisor(Moongate.FiberSupervisor, [], [id: :fiber]),
      supervisor(Moongate.RingSupervisor, [], [id: :ring]),
      supervisor(Moongate.SessionSupervisor, [], [id: :session]),
      supervisor(Moongate.SocketSupervisor, [], [id: :socket]),
      supervisor(Moongate.ZoneSupervisor, [], [id: :zone])
    ]
    ++ [extension(:dev, config)]
    ++ [extension(:logger, config)]
    |> supervise(strategy: :one_for_one)
  end

  # Returns a worker for the given module name
  # if the module has been compiled and loaded.
  defp extension(module_name, %CoreConfig{} = config) do
    case @extensions[module_name] do
      module when is_atom(module) ->
        if Code.ensure_loaded?(module) do
          worker(module, [config], [id: module_name])
        else
          []
        end
      _ -> []
    end
  end
end
