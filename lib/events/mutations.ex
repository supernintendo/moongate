defmodule Moongate.Event.Mutations do
  @moduledoc """
    Provides functions which mutate the state of an
    event process.
  """
  def mutation({:join_stage, stage_name}, event, state) do
    Moongate.Service.Stages.arrive(event.origin, stage_name)

    {:stages, state.stages ++ [stage_name]}
  end

  @doc """
    Remove a stage from the joined stages list.
  """
  def mutation({:leave_from, origin}, event, state) do
    {:stages, Enum.filter(state.stages, &(&1 != event.from)) }
  end

  @doc """
    Set a stage as the target stage, causing incoming messages
    to be sent to that stage.
  """
  def mutation({:set_target_stage, stage_name}, _event, state) do
    {:target_stage, stage_name}
  end
end
