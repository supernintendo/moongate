defmodule Moongate.StageEvent do
  defstruct from: nil, origin: nil, params: nil
end

defmodule Moongate.StageInstance do
  defstruct(
    events: %{},
    id: nil,
    members: [],
    pools: [],
    stage: nil
  )
end

defmodule Moongate.Stages.Instance do
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.Processes

  def start_link(params) do
    id = params[:id]
    link(%Moongate.StageInstance{id: id, stage: params[:stage]}, "stage", "#{id}")
  end

  def handle_cast({:init}, state) do
    state = initialize_pools(state)
    {:noreply, state}
  end

  def handle_cast({:bubble, event, from, key}, state) do
    state.pools |> Enum.map(&(bubble_to(&1, event, from, key)))
    {:noreply, state}
  end

  def handle_cast({:echo, event, from, params}, state) do
    apply(state.stage, :echo, [event, from, params])
    {:noreply, state}
  end

  @doc """
    Remove a Moongate.SocketOrigin from the stage.
  """
  def handle_cast({:depart, event}, state) do
    is_member_of = Enum.any?(state.members, &(&1 == event.origin.id))

    if is_member_of do
      manipulation = %{state | members: Enum.filter(state.members, &(&1 != event.origin.id))}
      write_to(event.origin, :transaction, "leave")
      Moongate.Say.pretty("#{Moongate.Say.origin(event.origin)} left stage #{state.id}.", :blue)
      apply(state.stage, :departure, [event])
      {:noreply, manipulation}
    else
      {:noreply, state}
    end
  end

  @doc """
    Add a Moongate.SocketOrigin to the stage and subscribe it to
    all pools.
  """
  def handle_cast({:arrive, origin}, state) do
    is_member_of = Enum.any?(state.members, &(&1 == origin.id))

    if is_member_of do
      {:noreply, state}
    else
      manipulation = %{state | members: Enum.uniq(state.members ++ [origin.id])}
      event = %Moongate.StageEvent{
        from: Process.info(self())[:registered_name],
        origin: origin
      }
      apply(state.stage, :arrival, [event])
      Enum.map(state.pools, &(tell_async(:pool, &1, {:describe, origin})))
      write_to(origin, :transaction, "join")
      Moongate.Say.pretty("#{Moongate.Say.origin(origin)} joined stage #{state.id}.", :cyan)
      {:noreply, manipulation}
    end
  end

  @doc """
    Receive a message from an event listener and if the origin on the
    event is qualified, call the callback defined on the stage
    module.
  """
  def handle_cast({:tunnel, event}, state) do
    cast = event.cast
    params = event.params
    event = %Moongate.StageEvent{
      from: Process.info(self())[:registered_name],
      origin: event.origin
    }
    is_member_of = Enum.any?(state.members, &(&1 == event.origin.id))
    if is_member_of, do: apply(state.stage, :__moongate__stage_takes, [{cast, params}, event])

    {:noreply, state}
  end

  def handle_cast({:pool_publish, pool, pid, tag}, state) do
    ["Elixir", pool_name] = String.split(Atom.to_string(pool), ".")
    name = "#{Atom.to_string(state.id)}_#{String.downcase(pool_name)}"
    tell_async(:pool, name, {:publish_to, pid, tag})
    {:noreply, state}
  end

  @doc """
    Initialize all pools.
  """
  def initialize_pools(state) do
    pools = apply(state.stage, :__moongate__stage_pools, [])
    pools = Enum.map(pools, &(initialize_pool(&1, state)))
    state = %{state | pools: pools}
  end

  @doc """
    Initialize one pool.
  """
  def initialize_pool(pool_module, state) do
    prefix = Atom.to_string(state.id)
    suffix_parts = tl(String.split(Atom.to_string(pool_module), "."))
    suffix = List.to_string(Enum.map(suffix_parts, &("_" <> String.downcase(&1))))
    process_name = prefix <> suffix
    {:ok, pid} = spawn_new(:pool, {process_name, state.id, pool_module})
    String.to_atom(process_name)
  end

  defp bubble_to(pool, event, from, key) do
    pool_name = String.to_atom("pool_#{Atom.to_string(pool)}")
    GenServer.cast(pool_name, {:bubble, event, from, key})
  end
end
