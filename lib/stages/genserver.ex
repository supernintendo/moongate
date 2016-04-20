defmodule Moongate.Stage.GenServer do
  import Moongate.Macros.SocketWriter
  import Moongate.Stage.Mutations
  use GenServer
  use Moongate.Macros.Mutations, genserver: true
  use Moongate.Macros.Processes

  @doc """
    Start the stage process.
  """
  def start_link(params) do
    %Moongate.Stage.GenServer.State{
      id: params[:id],
      stage: params[:stage]
    }
    |> link("stage", "#{params[:id]}")
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    {:noreply, state |> init_pools}
  end

  @doc """
    Receive a message from an event listener and call
    the callback defined on the stage module.
  """
  def handle_cast({:tunnel, event}, state) do
    apply(state.stage, :takes, [{event.cast, event.params}, %{ event | from: state.id }])
    |> mutations(state)
    |> no_reply
  end

  @doc """
    Mutate the stage state to account for a dropped
    member.
  """
  def handle_cast({:depart, event}, state) do
    apply(state.stage, :departure, [event])
    |> mutations(state)
    |> no_reply
  end

  @doc """
    Mutate the stage state to account for a new
    member based on the result of calling `arrival`
    on the stage module.
  """
  def handle_call({:arrive, origin}, _from, state) do
    apply(state.stage, :arrival, [
      %Moongate.StageEvent{
        from: Process.info(self)[:registered_name],
        origin: origin
      }])
    |> mutate({:join_this_stage, origin})
    |> mutations(state)
    |> reply(:ok)
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
