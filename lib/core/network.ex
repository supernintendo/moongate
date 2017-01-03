defmodule Moongate.CoreNetwork do
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
  Performs a GenServer.start_link for the
  specified module.
  """
  def establish(params, module), do: GenServer.start_link(module, params)
  def establish(params, name, module) do
    GenServer.start_link(module, params, [name: String.to_atom(name)])
  end
  def establish(params, namespace, name, module) do
    GenServer.start_link(module, params, [name: String.to_atom(namespace <> name)])
  end

  @doc """
  Returns a list of all processes within a supervisor,
  specified by its name suffix within the ETS table
  for the corresponding supervision tree.
  """
  def list(namespace) do
    supervisor_name = "tree_#{namespace}"

    case Moongate.CoreETS.lookup({:registry, "tree_#{namespace}"}) do
      [{^supervisor_name, supervisor}] -> Supervisor.which_children(supervisor)
      [] -> []
    end
  end

  @doc """
  Kills a process by pid or name suffix within the
  process registry's ETS table.
  """
  def kill_process(pid) when is_pid(pid) do
    results = Moongate.CoreETS.match_object({:registry, {:_, pid}})

    results
    |> Enum.map(fn({key, _}) ->
      Moongate.CoreETS.delete({:registry, key})
    end)
    :ok
  end
  def kill_process({namespace, pid}) do
    supervisor_name = "tree_#{namespace}"

    case Moongate.CoreETS.lookup({:registry, "tree_#{namespace}"}) do
      [{^supervisor_name, supervisor}] -> Supervisor.terminate_child(supervisor, pid)
      [] -> nil
    end
  end

  @doc """
  Returns the PID for a process by its name within
  the process registry's ETS table if it exists.
  """
  def pid_for_name(name) do
    case Moongate.CoreETS.lookup({:registry, name}) do
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
  def register(params, namespace), do: register(params, namespace, UUID.uuid4(:hex))
  def register(params, namespace, name) do
    supervisor_name = "tree_#{namespace}"

    case Moongate.CoreETS.lookup({:registry, supervisor_name}) do
      [{^supervisor_name, supervisor}] ->
        {:ok, child} = Supervisor.start_child(supervisor, [params])
        Moongate.CoreETS.insert({:registry, "#{namespace}_#{name}", child})
        GenServer.cast(child, :init)
        child
      [] -> nil
    end
  end

  @doc """
  Sends a packet string to a target or list of
  targets.
  """
  def send_packet(packet, targets) when is_list(targets) do
    for target <- targets, do: send_packet(packet, target)
  end
  def send_packet(packet, %Moongate.CoreOrigin{} = target) do
    send(target.port, {:write, packet})
  end
  def send_packet(_packet, _target), do: nil
end
