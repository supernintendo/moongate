defmodule Moongate.CoreNetwork do
  alias Moongate.{
    Core,
    CoreConfig,
    CoreETS,
    CoreOrigin
  }

  @doc """
  Performs a GenServer.cast to every GenServer
  under a given supervisor.
  """
  def cascade(message, supervisor_name) do
    for {_, pid, _, _} <- list(supervisor_name) do
      cast(message, pid)
    end
  end

  @doc """
  Performs a GenServer.call to a GenServer by pid
  or name within the registry ETS table.
  """
  def call(message, pid) when is_pid(pid) do
    GenServer.call(pid, message)
  end
  def call(message, name) do
    pid = pid_for_name(name)

    case is_pid(pid) do
      true -> call(message, pid)
      false -> {:error, :no_pid}
    end
  end

  @doc """
  Performs a GenServer.cast to a GenServer by pid
  or name within the registry ETS table.
  """
  def cast(message, pid) when is_pid(pid) do
    GenServer.cast(pid, message)
  end
  def cast(message, name) do
    pid = pid_for_name(name)
    if is_pid(pid), do: cast(message, pid)
  end
  def cast(message, namespace, id) do
    pid = pid_for_name("#{namespace}_#{id}")
    if is_pid(pid), do: cast(message, pid)
  end

  @doc """
  Returns a list of all processes within a supervisor,
  specified by its name suffix within the ETS table
  for the corresponding supervision tree.
  """
  def list(namespace) do
    supervisor_name = "tree_#{namespace}"

    case CoreETS.lookup({:registry, "tree_#{namespace}"}) do
      [{^supervisor_name, supervisor}] -> Supervisor.which_children(supervisor)
      [] -> []
    end
  end

  @doc """
  Kills a process by pid or name suffix within the
  process registry's ETS table.
  """
  def kill_process(pid) when is_pid(pid) do
    results = CoreETS.match_object({:registry, {:_, pid}})

    results
    |> Enum.map(fn({key, _}) ->
      CoreETS.delete({:registry, key})
    end)
    :ok
  end
  def kill_process({namespace, pid}) do
    supervisor_name = "tree_#{namespace}"

    case CoreETS.lookup({:registry, "tree_#{namespace}"}) do
      [{^supervisor_name, supervisor}] -> Supervisor.terminate_child(supervisor, pid)
      [] -> nil
    end
  end

  @doc """
  Returns a string representation of the IP address
  of the current node on the local network.

  ## Example

      iex> Moongate.Network.local_ip
      "10.11.12.1"
  """
  def local_ip do
    {:ok, parts} = :inet.getif
    parts
    |> hd
    |> elem(0)
    |> Tuple.to_list
    |> Enum.join(".")
  end

  @doc """
  Returns the PID for a process by its name within
  the process registry's ETS table if it exists.
  """
  def pid_for_name(name) do
    case CoreETS.lookup({:registry, name}) do
      [{^name, pid}] -> pid
      _ -> nil
    end
  end

  @doc """
  Starts a new child process within the specified
  supervisor and stores the PID in ETS. The namespace
  refers to the suffix of the supervisor key and
  process key in the ETS tables of the supervision
  tree and process registry respectively.
  """
  def register(namespace), do: register(nil, namespace)
  def register(params, namespace), do: register(params, namespace, Core.uuid(namespace))
  def register(params, namespace, name) do
    supervisor_name = "tree_#{namespace}"

    case CoreETS.lookup({:registry, supervisor_name}) do
      [{^supervisor_name, supervisor}] ->
        {:ok, child} = Supervisor.start_child(supervisor, [params, name])
        CoreETS.insert({:registry, "#{namespace}_#{name}", child})
        GenServer.cast(child, :init)
        child
      [] -> nil
    end
  end

  @doc """
  Sends a packet string to a target or list of
  targets.
  """
  def send_packet(packets, target_or_targets) when is_list(packets) do
    for packet <- packets, do: send_packet(packet, target_or_targets)
  end
  def send_packet(packet, targets) when is_list(targets) do
    for target <- targets, do: send_packet(packet, target)
  end
  def send_packet(packet, %CoreOrigin{} = target) do
    send(target.port, {:write, packet})
  end
  def send_packet(_packet, _target), do: nil

  def spawn_endpoints(%CoreConfig{endpoints: endpoints}) do
    endpoints
    |> Enum.map(fn {port, params} ->
      register({port, params}, :socket, "socket_#{port}")
    end)
    :ok
  end

  def spawn_fibers(%CoreConfig{autoreload: autoreload}) do
    if autoreload do
      register(%{
        fiber_module: Moongate.Fibers.DevWatcher
      }, :fiber, "fiber_dev_watcher")
    end
    :ok
  end

  def spawn_supervisor(%CoreConfig{} = config) do
    {:ok, supervisor} = Moongate.CoreSupervisor.start_link(config)

    supervisor
    |> Supervisor.which_children
    |> Enum.map(fn({name, pid, _type, _params}) ->
      Moongate.CoreETS.insert({:registry, "tree_#{name}", pid})
    end)

    supervisor
  end
end
