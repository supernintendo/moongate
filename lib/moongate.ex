defmodule Moongate do
  @moduledoc """
    The Moongate Application Platform.
  """
  alias Moongate.{
    Core,
    CoreEvent,
    CoreLoader,
    CoreNetwork
  }
  require Moongate.CoreLoader
  use Application

  @before_compile Moongate.CoreLoader
  @packet Application.get_env(:moongate, :packet)

  def start(_type, _args) do
    config = CoreLoader.load_config()
    supervisor = CoreNetwork.spawn_supervisor(config)
    :ok = CoreNetwork.spawn_fibers(config)
    :ok = CoreNetwork.spawn_endpoints(config)
    :ok = @packet.init()
    CoreNetwork.cast(:refresh, Process.whereis(:dev))
    %CoreEvent{}
    |> Core.trigger(:start)
    |> Core.dispatch()

    {:ok, supervisor}
  end

  def stop(_state) do
    :ok
  end

  def version do
    {:ok, version} = :application.get_key(:moongate, :vsn)

    "#{version}"
  end
end
