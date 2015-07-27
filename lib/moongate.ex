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
    flags = load_flags(world)
    supervisor = start_supervisor(world)
    Say.greeting
    spawn_sockets(world)
    tell_sync(:auth, {:no_auth, flags["no_auth"]})
    recur

    {:ok, supervisor}
  end

  defp load_flags(world) do
    {:ok, read} = File.read "worlds/#{world}/flags.json"
    {:ok, flags} = JSON.decode(read)
    flags
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

  defp start_supervisor(world) do
    {:ok, read} = File.read "worlds/#{world}/supervisors.json"
    {:ok, world_supervisors} = JSON.decode(read)
    {:ok, supervisor} = Moongate.Supervisor.start_link(world_supervisors)
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
    Say.pretty "Compiled #{filename}.", :yellow
    Code.eval_file(filename)
  end

  # Fairly straightforward.
  defp recur do
    recur
  end
end