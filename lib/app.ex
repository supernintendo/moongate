defmodule Moongate.Application do
  @moduledoc """
    The Moongate Application Platform.
  """
  use Application
  use Moongate.OS

  ### Public

  @doc """
    Initialize the game server.
  """
  def start(_type, _args) do
    load_world
    config = load_config
    supervisor = start_supervisor(config)
    spawn_fibers(config)
    spawn_sockets(config)
    create_handshake(config)
    Moongate.World.Service.world_apply(:start)

    if Mix.env() == :prod, do: recur

    {:ok, supervisor}
  end

  def stop(_state) do
    :ok
  end

  ### Private

  defp create_handshake(config) do
    if File.exists?("priv/#{world_directory}/.handshake.json") do
      File.rm("priv/#{world_directory}/.handshake.json")
    end
    handshake = %{
      ip: Moongate.Network.get_ip,
      sockets: config.sockets || %{}
    }
    {:ok, json} = JSON.encode(handshake)
    {:ok, file} = File.open("priv/#{world_directory}/.handshake.json", [:write])
    IO.binwrite(file, json)
  end

  # Load the server.json file for the world.
  defp load_config, do: load_config(Moongate.World.Service.get_world)
  defp load_config(world) do
    if File.exists?("priv/worlds/#{world}/moongate.eon") do
      {:ok, config} = EON.from_file("priv/worlds/#{world}/moongate.eon")

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
  defp load_world, do: load_world(Moongate.World.Service.get_world, "#{Moongate.World.Service.get_world}/server")
  defp load_world(world, path) do
    dir = File.ls("priv/worlds/#{path}")
    load_all_in_directory(dir, world, path)

    world
  end

  # Load all files within a world subdirectory.
  defp load_all_in_directory({:ok, dir}, world, path) do
    # Evaluate all .ex files.
    dir
    |> Enum.filter(&(Regex.match?(~r/.ex\b/, &1)))
    |> Enum.map(&("priv/worlds/#{path}/#{&1}"))
    |> Enum.map(&Code.eval_file(&1))

    # Pass subdirectories back into the pipeline to
    # facilitate deep loading of a world's directory
    # tree.
    dir
    |> Enum.filter(&(File.dir?(Path.expand("priv/worlds/#{path}/#{&1}"))))
    |> Enum.map(&(load_world(world, "#{path}/#{&1}")))
  end

  defp spawn_fibers(config) do
    if config[:fibers] do
      config[:fibers]
      |> Enum.map(&Moongate.Fiber.Service.spawn_fiber/1)
    end
  end

  # Spawn socket listeners as they are defined in
  # the world's ports.json.
  defp spawn_sockets(config) do
    config.sockets |> Enum.map(&spawn_socket(&1))
  end

  # Start the supervision tree.
  defp start_supervisor(config) do
    {:ok, supervisor} = Moongate.Supervisor.start_link(config)

    supervisor
    |> Supervisor.which_children
    |> Enum.map(fn({name, pid, _type, _params}) ->
      Moongate.Processes.insert({"tree_#{name}", pid})
    end)

    supervisor
  end

  # Give an entry from ports.json, spawn a socket with the
  # appropriate protocol on the provided port.
  defp spawn_socket({protocol, {port, params}}) do
    register(protocol, "#{port}", {port, params})
  end
  defp spawn_socket({protocol, port}) do
    register(protocol, "#{port}", port)
  end

  # Fairly straightforward.
  defp recur do
    recur
  end
end
