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
    configure_console
    spawn_fibers(config)
    spawn_endpoints(config)
    Moongate.Core.world_apply(:start)

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

  def configure_console do
    if IEx.started? do
      Application.put_env(:elixir, :ansi_enabled, true)
      IEx.configure(
        default_prompt: "",
        history_size: -1
      )
    end
  end

  # Load the server.json file for the world.
  defp load_config, do: load_config(Moongate.Core.world_name)
  defp load_config(world) do
    if File.exists?("priv/worlds/#{world}/moongate.exs") do
      {:ok, config} = EON.from_file("priv/worlds/#{world}/moongate.exs")

      config
    else
      {:error, nil}
    end
  end

  defp load_world, do: load_world(Moongate.Core.world_name, "#{Moongate.Core.world_name}/server")
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
    unless Map.has_key?(config, :dont_watch) && config.dont_watch do
      Moongate.Network.register(:fiber, "world_watcher", {"world_watcher", %{
        fiber_module: Moongate.Fibers.WorldWatcher
      }})
    end
  end

  defp spawn_endpoints(config) do
    config.endpoints |> Enum.map(&spawn_endpoint(&1))
  end

  defp spawn_endpoint({name, {protocol, params}}) do
    Moongate.Network.register(protocol, "endpoint_#{name}", {name, params})
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
end
