defmodule Moongate.Session.Mutations do
  @moduledoc """
    Provides functions which mutate the state of an
    event process.
  """
  def mutation({:join_stage, stage_name, id}, event, state) do
    Moongate.Stage.Service.arrive(event.origin, stage_name, id)

    {:stages, state.stages ++ [Moongate.Stage.Service.stage_process_name(stage_name, id)]}
  end

  @doc """
    Remove a stage from the joined stages list.
  """
  def mutation({:leave_from, _origin}, event, state) do
    {:stages, Enum.filter(state.stages, &(&1 != event.from)) }
  end

  @doc """
    Set a stage as the target stage, causing incoming messages
    to be sent to that stage.
  """
  def mutation({:set_target_stage, stage_module, id}, _event, _state) do
    {:target_stage, Moongate.Stage.Service.stage_process_name(stage_module, id)}
  end
end
