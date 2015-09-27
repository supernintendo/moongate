defmodule Moongate.SupervisionTree do
  use GenServer
  use Moongate.Macros.Processes

  def start_link do
    link(%{}, "tree")
  end

  def init(registry) do
    {:ok, registry}
  end

  @doc """
    Cast on all children of a supervisor.
  """
  def handle_cast({:tell_async_all_children, supervisor, cast}, registry) do
    children = Supervisor.which_children(registry[supervisor])
    Enum.map(children, &tell_pid_async(elem(&1, 1), cast))
    {:noreply, registry}
  end

  @doc """
    Keep track of all master supervisors.
  """
  def handle_call({:register, supervisor}, _from, _) do
    updated = supervisor
    |> Supervisor.which_children
    |> Enum.filter(&not_self(&1))
    |> Enum.reduce(%{}, &assign_children(&1, &2))

    {:reply, nil, updated}
  end

  @doc """
    Kill a child process given its PID.
  """
  def handle_call({:kill_by_pid, supervisor, pid}, _from, registry) do
    :ok = Supervisor.terminate_child(registry[supervisor], pid)

    {:reply, {:ok, nil}, registry}
  end

  @doc """
    Spawn a new child within the requested supervisor.
  """
  def handle_call({:spawn, supervisor, params}, _from, registry) do
    {:ok, child} = Supervisor.start_child(registry[supervisor], [params])
    tell_pid_async(child, {:init})

    {:reply, {:ok, child}, registry}
  end

  # Accumulate child processes.
  defp assign_children(child, acc) do
    Map.put(acc, elem(child, 0), elem(child, 1))
  end

  # Return every child that isn't the supervision tree.
  defp not_self(worker) do
    elem(worker, 1) != self()
  end
end
