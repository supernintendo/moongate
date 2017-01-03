defmodule Moongate.ZoneMutations do
  use Moongate.CoreState

  def mutate({:add_member, origin}, event, state) do
    {{:members, Map.put(state.members, origin.id, origin)}, event}
  end

  def mutate({:remove_member, origin}, event, state) do
    {{:members, Map.drop(state.members, [origin.id])}, event}
  end

  def mutate({:subscribe_to_ring, ring}, event, state) do
    for target <- event.targets do
      target
      |> Moongate.RingService.subscribe_to_ring({ring, state.name, state.id})
    end
    {nil, event}
  end
end
