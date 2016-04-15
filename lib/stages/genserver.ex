defmodule Moongate.Stage.GenServer do
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.Processes

  def start_link(params) do
    %Moongate.Stage.GenServer.State{
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
    apply(state.stage, :takes, [{event.cast, event.params}, %{ event | from: state.id }])
    |> mutations(state)
    |> no_reply
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

  def handle_cast({:depart, event}, state) do
    apply(state.stage, :departure, [event])
    |> mutations(state)
    |> no_reply
  end

  def handle_call({:arrive, origin}, _from, state) do
    apply(state.stage, :arrival, [
      %Moongate.StageEvent{
        from: Process.info(self)[:registered_name],
        origin: origin
      }])
    |> Moongate.Data.mutate({:join_this_stage, origin})
    |> mutations(state)
    |> reply(:ok)
  end

  defp mutations(event, state) do
    (for mut <- event.mutations, do: mutation(mut, event, state))
    |> Enum.filter(&(&1 != nil))
    |> Enum.into(state)
  end

  defp mutation({:join_stage, stage_name}, event, state) do
    tell_pid!({:mutations, event}, event.origin.event_listener)
    nil
  end

  defp mutation({:join_this_stage, origin}, _event, state) do
    {:members, state.members ++ [origin]}
  end

  defp mutation({:leave_from, origin}, _event, state) do
    state.pools
    |> Enum.map(&(tell({:remove_from_pool, origin}, :pool, &1)))

    {:members, Enum.filter(state.members, &(&1.id != origin.id))}
  end

  defp mutation({:subscribe_to_pool, pool}, event, state) do
    process = Moongate.Pool.Service.pool_process(state.id, Moongate.Atoms.to_strings(pool))
    tell({:subscribe, event}, process)
    nil
  end

  defp mutation({:create_in_pool, pool, params}, _event, state) do
    IO.puts "TODO: Create in pool"
    nil
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

    spawn_new(:pool, {process_name, state.id, pool})

    String.to_atom(process_name)
  end
end
