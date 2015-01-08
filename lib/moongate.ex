defmodule Moongate do
  use Application

  @doc """
    Initialize the game server.
  """
  def start(_type, _args) do
    {:ok, read} = File.read "pkg/configs/default.json"
    {:ok, config} = JSON.decode(read)

    Say.greeting
    {:ok, supervisor} = Moongate.Supervisor.start_link
    GenServer.call(:tree, {:register, supervisor})
    config["ports"] |> Enum.map(&start_socket(&1))
    config["worlds"] |> Enum.map(&start_world(&1))
    start_all_areas

    {:ok, supervisor}
  end

  defp start_socket(port) do
    GenServer.call(:tree, {:spawn, :sockets, port})
  end

  defp start_world(world) do
    GenServer.call(:tree, {:spawn, :worlds, world})
  end

  defp start_all_areas do
    GenServer.cast(:tree, {:cast_to_all_children, :worlds, {:spawn_all_areas}})
  end
end
