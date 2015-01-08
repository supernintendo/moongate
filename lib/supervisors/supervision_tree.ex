defmodule SupervisionTree do
  use GenServer
  use Mixins.SocketWriter
  use Mixins.Store

  def start_link do
    GenServer.start_link(__MODULE__, %{}, [name: :tree])
  end

  def init(registry) do
    {:ok, registry}
  end

  @doc """
    Cast on all children of a supervisor.
  """
  def handle_cast({:cast_to_all_children, supervisor, cast}, registry) do
    children = Supervisor.which_children(registry[supervisor])
    Enum.map(children, &cast_to(&1, cast))
    {:noreply, registry}
  end

  @doc """
    Send information about all children of a supervisor to the client.
  """
  def handle_cast({:get, supervisor, event}, registry) do
    children = Supervisor.which_children(registry[supervisor])
    children_info = Enum.map(Enum.map(children, fn(child) -> elem(child, 1) end), fn(pid) ->
      [GenServer.call(pid, :give_info), "|"]
    end)
    write_to(event.origin, %{
      cast: :info,
      namespace: supervisor,
      value: List.to_string(List.flatten(children_info))
    })
    {:noreply, registry}
  end

  @doc """
    Keep track of all master supervisors.
  """
  def handle_call({:register, supervisor}, _from, registry) do
    updated = supervisor
    |> Supervisor.which_children
    |> Enum.filter(&not_self(&1))
    |> Enum.reduce(%{}, &assign_children(&1, &2))

    {:reply, nil, updated}
  end

  @doc """
    Spawn a new child within the requested supervisor.
  """
  def handle_call({:spawn, supervisor, params}, _from, registry) do
    {:ok, child} = Supervisor.start_child(registry[supervisor], [params])
    GenServer.cast(child, {:init})

    {:reply, {:ok, child}, registry}
  end

  # Accumulate child processes.
  defp assign_children(child, acc) do
    Map.put(acc, elem(child, 0), elem(child, 1))
  end

  defp cast_to(child, cast) do
    {_, process, _, _} = child
    GenServer.cast(process, cast)
  end

  # Return every child that isn't the supervision tree.
  defp not_self(worker) do
    elem(worker, 1) != self()
  end
end