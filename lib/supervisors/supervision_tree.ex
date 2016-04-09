defmodule Moongate.SupervisionTreeState do
  defstruct table: nil
end

defmodule Moongate.SupervisionTree do
  use GenServer
  use Moongate.Macros.Processes

  def start_link do
    %Moongate.SupervisionTreeState{
      table: :ets.new(:supervision_tree, [:set, :protected])
    }
    |> link("tree")
  end

  def init(state) do
    {:ok, state}
  end

  @doc """
    Cast on all children of a supervisor.
  """
  def handle_cast({:tell_all, supervisor, cast}, state) do
    state[supervisor]
    |> Supervisor.which_children
    |> Enum.map(&tell_pid(cast, elem(&1, 1)))

    {:noreply, state}
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
  def handle_call({:kill_by_pid, supervisor, pid}, _from, state) do
    :ok = Supervisor.terminate_child(state[supervisor], pid)

    {:reply, {:ok, nil}, state}
  end

  @doc """
    Spawn a new child within the requested supervisor.
  """
  def handle_call({:spawn, supervisor, params}, _from, state) do
    {:ok, child} = Supervisor.start_child(state[supervisor], [params])
    tell_pid({:init}, child)

    {:reply, child, state}
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
