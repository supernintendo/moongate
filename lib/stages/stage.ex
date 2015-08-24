defmodule Moongate.StageTransaction do
  defstruct from: nil, origin: nil
end

defmodule Moongate.StageInstance do
  defstruct events: %{}, id: nil, members: [], pools: %{}, stage: nil
end

defmodule Moongate.Stages.Instance do
  use GenServer
  use Moongate.Macros.Processes

  def start_link(params) do
    id = params[:id]
    link(%Moongate.StageInstance{id: id, stage: params[:stage]}, "stage", "#{id}")
  end

  def handle_cast({:init}, state) do
    initialize_pools(state)
    {:noreply, state}
  end

  def handle_cast({:kick, origin}, state) do
    is_member_of = Enum.any?(state.members, &(&1 == origin.id))

    if is_member_of do
      manipulation = %{state | members: Enum.filter(state.members, &(&1 != origin.id))}
      Moongate.Say.pretty("#{Moongate.Say.origin(origin)} left stage #{state.id}.", :blue)
      {:noreply, manipulation}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:join, origin}, state) do
    is_member_of = Enum.any?(state.members, &(&1 == origin.id))

    if is_member_of do
      {:noreply, state}
    else
      manipulation = %{state | members: Enum.uniq(state.members ++ [origin.id])}
      apply(state.stage, :joined, [origin])
      Moongate.Say.pretty("#{Moongate.Say.origin(origin)} joined stage #{state.id}.", :cyan)
      {:noreply, manipulation}
    end
  end

  def handle_cast({:tunnel, event}, state) do
    cast = event.cast
    params = event.params
    transaction = %Moongate.StageTransaction{
      from: Process.info(self())[:registered_name],
      origin: event.origin
    }
    is_member_of = Enum.any?(state.members, &(&1 == event.origin.id))
    if is_member_of, do: apply(state.stage, :__moongate__stage_takes, [{cast, params}, transaction])

    {:noreply, state}
  end

  def initialize_pools(state) do
    pools = apply(state.stage, :__moongate__stage_pools, [])
    Enum.map(pools, &initialize_pool/1)
  end

  def initialize_pool(_pool) do
  end
end