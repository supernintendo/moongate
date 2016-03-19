defmodule Moongate.Application do
  alias Moongate.Worlds, as: Worlds
  use Application
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  ### Public

  @doc """
    Initialize the game server.
  """
  def start(_type, _args) do
    :random.seed :os.system_time
    Moongate.Say.greeting
    load_world
    supervisor = load_config |> start_supervisor
    initialize_stages
    spawn_sockets(Worlds.get_world)

    if Mix.env() == :prod, do: recur

    {:ok, supervisor}
  end

  ### Private

  # Load the server.json file for the world.
  defp load_config, do: load_config(Worlds.get_world)
  defp load_config(world) do
    if File.exists?("priv/worlds/#{world}/server.json") do
      {:ok, read} = File.read "priv/worlds/#{world}/server.json"
      {:ok, config} = JSON.decode(read)

      config
    else
      {:error, nil}
    end
  end

  # Load all modules for game world. Modules are
  # evaluated, which leads to the setup of the game
  # server through modules using the Moongate DSL.
  # This is the entry point for your world
  # directory.
  defp load_world, do: load_world(Worlds.get_world, "#{Worlds.get_world}/server")
  defp load_world(world, path) do
    dir = File.ls("priv/worlds/#{path}")
    load_all_in_directory(dir, world, path)

    world
  end

  # Load all files within a world subdirectory.
  defp load_all_in_directory({:ok, dir}, world, path) do
    # Evaluate all .ex files.
    dir |> Enum.filter(&(Regex.match?(~r/.ex\b/, &1)))
        |> Enum.map(&("priv/worlds/#{path}/#{&1}"))
        |> Enum.map(&Code.eval_file(&1))

    # Pass subdirectories back into the pipeline to
    # facilitate deep loading of a world's directory
    # tree.
    dir |> Enum.filter(&(File.dir?(Path.expand("priv/worlds/#{path}/#{&1}"))))
        |> Enum.map(&(load_world(world, "#{path}/#{&1}")))
  end

  # Spawn socket listeners as they are defined in
  # the world's ports.json.
  defp spawn_sockets(world) do
    {:ok, read} = File.read "priv/worlds/#{world}/ports.json"
    {:ok, ports} = JSON.decode(read)

    ports |> Enum.map(&spawn_socket(&1))
  end

  # Start the supervision tree.
  defp start_supervisor(config) do
    {:ok, read} = File.read "priv/worlds/#{Worlds.get_world}/supervisors.json"
    {:ok, world_supervisors} = JSON.decode(read)
    {:ok, supervisor} = Moongate.Supervisor.start_link({world_supervisors, config})
    GenServer.call(:tree, {:register, supervisor})

    supervisor
  end

  # Give an entry from ports.json, spawn a socket with the
  # appropriate protocol on the provided port.
  defp spawn_socket({port, params}) do
    case params["protocol"] do
      "TCP" -> spawn_new(:tcp_sockets, String.to_integer(port))
      "UDP" -> spawn_new(:udp_sockets, String.to_integer(port))
      "WebSocket" -> spawn_new(:web_sockets, String.to_integer(port))
      "HTTP" -> spawn_new(:http_hosts, {String.to_integer(port), params["path"]})
    end
  end

  # Initialize all stages.
  defp initialize_stages do
    apply(world_module, :__moongate_stages, [])
    |> Enum.map(&initialize_stage(&1))
  end

  # Initialize one stage.
  defp initialize_stage({id, stage}) do
    spawn_new(:stages, [id: id, stage: stage])
  end

  # Fairly straightforward.
  defp recur do
    recur
  end
end
