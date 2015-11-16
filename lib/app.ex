defmodule Moongate.Application do
  use Application
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  @doc """
    Initialize the game server.
  """
  def start(_type, args) do
    if Mix.env() == :test do
      world = "test"
    else
      world = Application.get_env(:moongate, :world) || "default"
    end

    :random.seed(:erlang.now())
    Moongate.Say.greeting
    IO.puts "Starting world #{world}..."
    load_world(world)
    load_scopes(world)
    supervisor = start_supervisor(world)
    initialize_stages
    Moongate.Scopes.Start.on_load
    spawn_sockets(world)

    if Mix.env() == :prod, do: recur
    {:ok, supervisor}
  end

  # Load all modules for game world and set up macros using config files
  defp load_world(world) do
    load_world(world, "#{world}/modules")
  end

  defp load_world(world, path) do
    dir = File.ls("priv/worlds/#{path}")
    load_all_in_directory(dir, world, path)
  end

  defp load_all_in_directory({:ok, dir}, world, path) do
    dir |> Enum.filter(&(Regex.match?(~r/.ex\b/, &1)))
        |> Enum.map(&("priv/worlds/#{path}/#{&1}"))
        |> Enum.map(&load_world_module(&1))

    dir |> Enum.filter(&(File.dir?(Path.expand("priv/worlds/#{path}/#{&1}"))))
        |> Enum.map(&(load_world(world, "#{path}/#{&1}")))
  end

  # Spawn socket listeners
  defp spawn_sockets(world) do
    {:ok, read} = File.read "priv/worlds/#{world}/ports.json"
    {:ok, ports} = JSON.decode(read)
    ports |> Enum.map(&spawn_socket(&1))
  end

  defp start_supervisor(world) do
    {:ok, read} = File.read "priv/worlds/#{world}/supervisors.json"
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
    Moongate.Say.pretty "Compiled #{filename}.", :green, [suppress_timestamp: true]
  end

  defp load_scopes(world) do
    if File.dir?("priv/worlds/#{world}/modules/scopes") do
      {:ok, files} = File.ls("priv/worlds/#{world}/modules/scopes")
      Enum.map(files, &load_scope(&1, world))
    end
  end

  defp load_scope(filename, world) do
    Code.eval_file("priv/worlds/#{world}/modules/scopes/#{filename}")
  end

  defp initialize_stages do
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
