defmodule Moongate do
  use Application
  use Mixins.Translator

  @doc """
    Initialize the game server.
  """
  def start(_type, _args) do
    {:ok, read} = File.read "config/server.json"
    {:ok, config} = JSON.decode(read)

    Say.greeting
    {:ok, supervisor} = Moongate.Supervisor.start_link
    GenServer.call(:tree, {:register, supervisor})
    config["ports"] |> Enum.map(&spawn_new(:sockets, &1))
    config["worlds"] |> Enum.map(&spawn_new(:worlds, &1))
    tell_all_async(:worlds, {:spawn_all_areas})

    if config["no_auth"] do
      tell_sync(:auth, {:no_auth, config["no_auth"]})
    end

    {:ok, supervisor}
  end
end
