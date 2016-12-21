defmodule Moongate.Supervisor do
  use Supervisor

  @extensions %{
    console: Application.get_env(:moongate, :console),
    logger: Application.get_env(:moongate, :logger)
  }

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, [name: :supervisor])
  end

  def init(_config) do
    [
      worker(Moongate.ETS, [], [id: :ets]),
      worker(Moongate.Support, [], [id: :support]),
      supervisor(Moongate.Fiber.Supervisor, [], [id: :fiber]),
      supervisor(Moongate.Ring.Supervisor, [], [id: :ring]),
      supervisor(Moongate.Zone.Supervisor, [], [id: :zone]),
      supervisor(Moongate.Web.Supervisor, [], [id: :web])
    ]
    ++ [extension(:logger)]
    ++ [extension(:console)]
    |> supervise(strategy: :one_for_one)
  end

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
