defmodule Moongate.CoreSupervisor do
  use Supervisor

  @extensions %{
    console: Application.get_env(:moongate, :console),
    logger: Application.get_env(:moongate, :logger)
  }

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, [name: :supervisor])
  end

  @doc """
  Initializes the supervision tree.
  """
  def init(_config) do
    [
      worker(Moongate.CoreETS, [], [id: :ets]),
      worker(Moongate.CoreSupport, [], [id: :support]),
      supervisor(Moongate.FiberSupervisor, [], [id: :fiber]),
      supervisor(Moongate.RingSupervisor, [], [id: :ring]),
      supervisor(Moongate.ZoneSupervisor, [], [id: :zone]),
      supervisor(Moongate.WebSupervisor, [], [id: :web])
    ]
    ++ [extension(:logger)]
    ++ [extension(:console)]
    |> supervise(strategy: :one_for_one)
  end

  # Returns a worker for the given module name
  # if the module has been compiled and loaded.
  defp extension(module_name) do
    case @extensions[module_name] do
      module when is_atom(module) ->
        if Code.ensure_loaded?(module) do
          worker(module, [], [id: module_name])
        else
          []
        end
      _ -> []
    end
  end
end
