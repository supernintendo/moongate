defmodule Moongate do
  use Application

  @doc """
    Generic start.
  """
  def start(_type, args) do
    {:ok, self()}
  end
end

defmodule Mix.Tasks.Moongate.Up do
  use Macros.Translator

  @doc """
    Initialize the game server.
  """
  def run(args) do
    IO.inspect args
    world = if List.first(args), do: hd(args), else: "default"
    load_world(world)
    {:ok, read} = File.read "config/server.json"
    {:ok, config} = JSON.decode(read)

    Say.greeting
    {:ok, supervisor} = Moongate.Supervisor.start_link
    GenServer.call(:tree, {:register, supervisor})
    spawn_initial(config)
    tell_all_async(:sessions, {:spawn_all_areas})
    tell_sync(:auth, {:no_auth, true})
    recur

    {:ok, supervisor}
  end

  # Load all modules for game world and set up macros using config files
  defp load_world(world) do
    load_all_in_directory(File.ls("worlds/#{world}/modules"), world)
  end

  # Spawn socket listeners and initial sessions
  defp spawn_initial(config) do
    IO.inspect config
    config["ports"] |> Enum.map(&spawn_new(:tcp_sockets, &1))
    config["sessions"] |> Enum.map(&spawn_new(:sessions, &1))
    spawn_new(:udp_sockets, 2599)
  end

  # Load all world modules
  defp load_all_in_directory({:ok, files}, world) do
    files = Enum.filter(files, fn(filename) -> Regex.match?(~r/.ex\b/, filename) end)
    files = Enum.map(files, fn(filename) -> "worlds/#{world}/modules/#{filename}" end)
    Enum.map(files, &load_world_module(&1))
  end

  defp load_world_module(filename) do
    Code.eval_file(filename)
  end

  # Fairly straightforward.
  defp recur do
    recur
  end
end