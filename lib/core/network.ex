defmodule Moongate.Network do
  def cascade(message, namespace) do
    for {_, pid, _, _} <- list(namespace) do
      cast(message, pid)
    end
  end

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

  def establish(params, module), do: GenServer.start_link(module, params)
  def establish(params, name, module) do
    GenServer.start_link(module, params, [name: String.to_atom(name)])
  end
  def establish(params, namespace, name, module) do
    GenServer.start_link(module, params, [name: String.to_atom(namespace <> name)])
  end

  def list(namespace) do
    supervisor_name = "tree_#{namespace}"

    case Moongate.ETS.lookup({:registry, "tree_#{namespace}"}) do
      [{^supervisor_name, supervisor}] -> Supervisor.which_children(supervisor)
      [] -> []
    end    
  end

  def kill_pid(pid) when is_pid(pid) do
    results = Moongate.ETS.match_object({:registry, {:_, pid}})

    results
    |> Enum.map(fn({key, _}) ->
      Moongate.ETS.delete({:registry, key})
    end)
    :ok
  end

  def kill_pid({namespace, pid}) do
    supervisor_name = "tree_#{namespace}"

    case Moongate.ETS.lookup({:registry, "tree_#{namespace}"}) do
      [{^supervisor_name, supervisor}] -> Supervisor.terminate_child(supervisor, pid)
      [] -> nil
    end
  end

  def pid_for_name(name) do
    case Moongate.ETS.lookup({:registry, name}) do
      [{^name, pid}] -> pid
      _ -> nil
    end
  end

  def register(namespace), do: register(namespace, nil)
  def register(namespace, params), do: register(namespace, UUID.uuid4(:hex), params)
  def register(namespace, name, params) do
    supervisor_name = "tree_#{namespace}"

    case Moongate.ETS.lookup({:registry, supervisor_name}) do
      [{^supervisor_name, supervisor}] ->
        {:ok, child} = Supervisor.start_child(supervisor, [params])
        Moongate.ETS.insert({:registry, "#{namespace}_#{name}", child})
        GenServer.cast(child, {:init})
        child
      [] -> nil
    end
  end

  def send_packet(packet, targets) when is_list(targets) do
    for target <- targets, do: send_packet(packet, target)
  end
  def send_packet(packet, %Moongate.Origin{} = target) do
    send(target.port, {:write, packet})
  end
  def send_packet(_packet, _target), do: nil
end
