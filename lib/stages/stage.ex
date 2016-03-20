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
    %Moongate.StageInstance{
      id: params[:id],
      stage: params[:stage]
    }
    |> link("stage", "#{params[:id]}")
  end

  def handle_cast({:init}, state) do
    {:noreply, state |> init_pools}
  end

  def handle_cast({:relay, _event, _from, _key}, state) do
    {:noreply, state}
  end

  @doc """
    Receive a message from an event listener and if the origin on the
    event is qualified, call the callback defined on the stage
    module.
  """
  def handle_cast({:tunnel, event}, state) do
    exports = state.stage.__info__(:functions)

    if exports[:takes] == 2 do
      apply(state.stage, :takes, [{event.cast, event.params}, event])
    end

    {:noreply, state}
  end

  def handle_cast({:pool_publish, pool, pid, tag}, state) do
    pool_name = pool
    |> Atom.to_string
    |> String.split(".")
    |> tl
    |> hd

    tell({:publish_to, pid, tag}, :pool, "#{Atom.to_string(state.id)}_#{String.downcase(pool_name)}")

    {:noreply, state}
  end

  @doc """
    Remove a Moongate.SocketOrigin from the stage.
  """
  def handle_cast({:depart, event}, state) do
    if Enum.any?(state.members, &(&1 == event.origin.id)) do
      write_to(event.origin, :transaction, "leave")
      Moongate.Say.pretty("#{Moongate.Say.origin(event.origin)} left stage #{state.id}.", :blue)
      apply(state.stage, :departure, [event])

      {:noreply, %{state |
        members: state.members |> Enum.filter(&(&1 != event.origin.id))
      }}
    else
      {:noreply, state}
    end
  end

  @doc """
    Add a Moongate.SocketOrigin to the stage and subscribe it to
    all pools.
  """
  def handle_call({:arrive, origin}, _from, state) do
    is_member_of = Enum.any?(state.members, &(&1 == origin.id))

    if is_member_of do
      {:reply, :ok, state}
    else
      event = %Moongate.StageEvent{
        from: Process.info(self())[:registered_name],
        origin: origin
      }
      apply(state.stage, :arrival, [event])
      state.pools |> Enum.map(&(tell({:describe, origin}, :pool, &1)))
      write_to(origin, :transaction, ["define"] ++ apply(state.stage, :__moongate__stage_pools, []))
      Moongate.Say.pretty("#{Moongate.Say.origin(origin)} joined stage #{state.id}.", :cyan)
      {:reply, {:ok, event}, %{state |
        members: Enum.uniq(state.members ++ [origin.id])
      }}
    end
  end

  @doc """
    Initialize all pools.
  """
  def init_pools(state) do
    pools = state.stage
    |> apply(:__moongate__stage_pools, [])
    |> Enum.map(&(init_pool(&1, state)))

    %{state | pools: pools}
  end

  @doc """
    Initialize one pool.
  """
  def init_pool(pool, state) do
    process_name = "#{Atom.to_string(state.id)}_"
    <> (pool
        |> Atom.to_string
        |> String.split(".")
        |> tl
        |> Enum.map(&("_" <> String.downcase(&1)))
        |> List.to_string)

    {:ok, _pid} = spawn_new(:pool, {process_name, state.id, pool})

    String.to_atom(process_name)
  end
end
