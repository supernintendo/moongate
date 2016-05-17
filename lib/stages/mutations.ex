defmodule Moongate.Stage.Mutations do
  import Moongate.Macros.SocketWriter
  use Moongate.Macros.Processes

  def mutation({:join_stage, stage_name, id}, event, state) do
    ask_pid({:mutations, event}, event.origin.events)
    nil
  end

  def mutation({:join_this_stage, origin}, _event, state) do
    {:members, state.members ++ [origin]}
  end

  def mutation({:leave_from, origin}, event, state) do
    state.pools
    |> Enum.map(&(tell({:remove_from_pool, origin}, :pool, &1)))
    write_to(origin, :leave, "stage", "#{state.id}")

    {:members, Enum.filter(state.members, &(&1.id != origin.id))}
  end

  def mutation({:set_target_stage, _, _}, _, _), do: nil

  def mutation({:subscribe_to_pool, pool}, event, state) do
    process = Moongate.Pool.Service.pool_process_name(state.id, Moongate.Atoms.to_strings(pool))
    tell({:subscribe, event}, "pool", process)
    nil
  end

  def mutation({:create_in_pool, pool, params}, event, state) do
    process = Moongate.Pool.Service.pool_process_name(state.id, Moongate.Atoms.to_strings(pool))
    tell({:add_to_pool, Map.put(params, :origin, event.origin)}, "pool", process)
    nil
  end
end
