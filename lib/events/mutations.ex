defmodule Moongate.Event.Mutations do
  def mutation({:join_stage, stage_name}, event, state) do
    Moongate.Service.Stages.arrive(event.origin, stage_name)

    {:stages, state.stages ++ [stage_name]}
  end

  def mutation({:leave_from, origin}, event, state) do
    {:stages, Enum.filter(state.stages, &(&1 != event.from)) }
  end

  def mutation({:set_target_stage, stage_name}, _event, state) do
    {:target_stage, stage_name}
  end
end
