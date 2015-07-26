defmodule Moongate do
  use Application

  @doc """
    Generic start.
  """
  def start(_type, _args) do
    {:ok, self()}
  end
end

defmodule Mix.Tasks.Moongate.Up do
  use Macros.Translator

  @doc """
    Initialize the game server.
  """
  def run(args) do
    world = if List.first(args), do: hd(args), else: "default"
    load_world(world)
    supervisor = start_supervisor
    Say.greeting
    spawn_sockets(world)
    tell_sync(:auth, {:no_auth, true})
    recur

    {:ok, supervisor}
  end

  # Load all modules for game world and set up macros using config files
  defp load_world(world) do
    load_all_in_directory(File.ls("worlds/#{world}/modules"), world)
  end

  # Spawn socket listeners
  defp spawn_sockets(world) do
    {:ok, read} = File.read "worlds/#{world}/ports.json"
    {:ok, ports} = JSON.decode(read)
    ports |> Enum.map(&spawn_socket(&1))
  end

  defp start_supervisor do
    {:ok, supervisor} = Moongate.Supervisor.start_link
    GenServer.call(:tree, {:register, supervisor})
    supervisor
  end

  defp spawn_socket({port, params}) do
    case params["protocol"] do
      "TCP" -> spawn_new(:tcp_sockets, String.to_integer(port))
      "UDP" -> spawn_new(:udp_sockets, String.to_integer(port))
    end
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