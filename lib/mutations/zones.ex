defmodule Moongate.Zone.Mutations do
  use Moongate.OS

  def mutation({:join_zone, _zone_name, _id}, event, _state) do
    ask_pid({:mutations, event}, event.origin.events)
    nil
  end

  def mutation({:join_this_zone, origin}, _event, state) do
    {:members, state.members ++ [origin]}
  end

  def mutation({:leave_from, origin}, _event, state) do
    state.rings
    |> Enum.map(&(tell({:remove_from_ring, origin}, :ring, &1)))
    socket_message(origin, {:leave, :zone, "#{state.id}", ""})

    {:members, Enum.filter(state.members, &(&1.id != origin.id))}
  end

  def mutation({:set_target_zone, _, _}, _, _), do: nil

  def mutation({:subscribe_to_ring, ring}, event, state) do
    process = Moongate.Ring.Service.ring_process_name(state.id, Moongate.Atoms.to_strings(ring))
    tell({:subscribe, event}, "ring", process)
    nil
  end

  def mutation({:create_in_ring, ring, params}, event, state) do
    process = Moongate.Ring.Service.ring_process_name(state.id, Moongate.Atoms.to_strings(ring))
    tell({:add_to_ring, Map.put(params, :origin, event.origin)}, "ring", process)
    nil
  end
end
