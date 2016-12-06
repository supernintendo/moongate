defmodule Moongate.Application do
  @moduledoc """
    The Moongate Application Platform.
  """
  use Application

  ### Public

  def start(_type, _args) do
    load_world
    config = load_config
    supervisor = start_supervisor(config)
    spawn_fibers(config)
    spawn_sockets(config)
    Moongate.Core.world_apply(:start)

    if Mix.env() == :prod, do: recur

    {:ok, supervisor}
  end

  def stop(_state) do
    :ok
  end

  def version do
    {:ok, version} = :application.get_key(:moongate, :vsn)

    "#{version}"
  end

  ### Private

  # Load the server.json file for the world.
  defp load_config, do: load_config(Moongate.Core.get_world)
  defp load_config(world) do
    if File.exists?("priv/worlds/#{world}/moongate.exs") do
      {:ok, config} = EON.from_file("priv/worlds/#{world}/moongate.exs")

      config
    else
      {:error, nil}
    end
  end

  defp load_world, do: load_world(Moongate.Core.get_world, "#{Moongate.Core.get_world}/server")
  defp load_world(world, path) do
    dir = File.ls("priv/worlds/#{path}")
    load_all_in_directory(dir, world, path)

    world
  end

  defp load_all_in_directory({:ok, dir}, world, path) do
    dir
    |> Enum.filter(&(Regex.match?(~r/.ex\b/, &1)))
    |> Enum.map(&("priv/worlds/#{path}/#{&1}"))
    |> Enum.map(&Code.eval_file(&1))

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

  defp spawn_sockets(config) do
    config.sockets |> Enum.map(&spawn_socket(&1))
  end

  defp start_supervisor(config) do
    {:ok, supervisor} = Moongate.Supervisor.start_link(config)

    supervisor
    |> Supervisor.which_children
    |> Enum.map(fn({name, pid, _type, _params}) ->
      Moongate.ETS.insert({:registry, "tree_#{name}", pid})
    end)

    supervisor
  end

  defp spawn_socket({protocol, {port, params}}) do
    Moongate.Network.register(protocol, "#{port}", {port, params})
  end
  defp spawn_socket({protocol, port}) do
    Moongate.Network.register(protocol, "#{port}", port)
  end

  # Fairly straightforward.
  defp recur do
    recur
  end
end
