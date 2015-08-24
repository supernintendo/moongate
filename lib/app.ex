defmodule Moongate.Application do
  use Application

  @doc """
    Generic start.
  """
  def start(_type, _args) do
    {:ok, self()}
  end
end

defmodule Mix.Tasks.Moongate.Up do
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  @doc """
    Initialize the game server.
  """
  def run(_) do
    {:ok, read} = File.read "config/config.json"
    {:ok, config} = JSON.decode(read)

    world = config["world"] || "default"
    Moongate.Say.greeting
    IO.puts "Starting world #{world}..."
    load_world(world)
    load_scopes(world)
    supervisor = start_supervisor(world)
    initialize_stages(world)
    Moongate.Scopes.Start.on_load
    spawn_sockets(world)
    recur

    {:ok, supervisor}
  end

  # Load all modules for game world and set up macros using config files
  defp load_world(world) do
    load_world(world, "#{world}/modules")
  end

  defp load_world(world, path) do
    dir = File.ls("worlds/#{path}")
    load_all_in_directory(dir, world, path)
  end

  defp load_all_in_directory({:ok, dir}, world, path) do
    dir |> Enum.filter(&(Regex.match?(~r/.ex\b/, &1)))
        |> Enum.map(&("worlds/#{path}/#{&1}"))
        |> Enum.map(&load_world_module(&1))

    dir |> Enum.filter(&(File.dir?(Path.expand("worlds/#{path}/#{&1}"))))
        |> Enum.map(&(load_world(world, "#{path}/#{&1}")))
  end

  # Spawn socket listeners
  defp spawn_sockets(world) do
    {:ok, read} = File.read "worlds/#{world}/ports.json"
    {:ok, ports} = JSON.decode(read)
    ports |> Enum.map(&spawn_socket(&1))
  end

  defp start_supervisor(world) do
    {:ok, read} = File.read "worlds/#{world}/supervisors.json"
    {:ok, world_supervisors} = JSON.decode(read)
    {:ok, supervisor} = Moongate.Supervisor.start_link(world_supervisors)
    GenServer.call(:tree, {:register, supervisor})
    supervisor
  end

  defp spawn_socket({port, params}) do
    case params["protocol"] do
      "TCP" -> spawn_new(:tcp_sockets, String.to_integer(port))
      "UDP" -> spawn_new(:udp_sockets, String.to_integer(port))
      "WebSocket" -> spawn_new(:web_sockets, String.to_integer(port))
      "HTTP" -> spawn_new(:http_hosts, String.to_integer(port))
    end
  end

  defp load_world_module(filename) do
    Code.eval_file(filename)
    Moongate.Say.pretty "Compiled #{filename}.", :yellow, [suppress_timestamp: true]
  end

  defp load_scopes(world) do
    {:ok, files} = File.ls("worlds/#{world}/scopes")
    Enum.map(files, &load_scope(&1, world))
  end

  defp load_scope(filename, world) do
    Code.eval_file("worlds/#{world}/scopes/#{filename}")
  end

  defp initialize_stages(world) do
    stages = apply(world_module, :__moongate_stages, [])
    Enum.map(stages, &initialize_stage(&1))
  end

  defp initialize_stage({id, stage}) do
    spawn_new(:stages, [id: id, stage: stage])
  end

  # Fairly straightforward.
  defp recur do
    recur
  end
end