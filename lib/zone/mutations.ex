defmodule Moongate.Zone.Mutations do
  use Moongate.Core

  def mutate({:join_zone, _zone_name, _id}, event, _state) do
    ask_pid({:mutations, event}, event.origin.events)
    nil
  end

  def mutate({:join_this_zone, origin}, _event, state) do
    {:members, state.members ++ [origin]}
  end

  def mutate({:leave_from, origin}, _event, state) do
    state.rings
    |> Enum.map(&(tell({:remove_from_ring, origin}, :ring, &1)))
    socket_message(origin, {:leave, :zone, "#{state.id}", ""})

    {:members, Enum.filter(state.members, &(&1.id != origin.id))}
  end

  def mutate({:set_target_zone, _, _}, _, _), do: nil

  def mutate({:subscribe_to_ring, ring}, event, state) do
    process = Moongate.Ring.Service.ring_process_name(state.id, Moongate.Utility.atoms_to_strings(ring))
    tell({:subscribe, event}, "ring", process)
    nil
  end

  def mutate({:create_in_ring, ring, params}, event, state) do
    process = Moongate.Ring.Service.ring_process_name(state.id, Moongate.Utility.atoms_to_strings(ring))
    tell({:add_to_ring, Map.put(params, :origin, event.origin)}, "ring", process)
    nil
  end
end
