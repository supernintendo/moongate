defmodule Moongate do
  @moduledoc """
    Provides macros for the World module of a
    Moongate world (the World module is the
    entry point of the world).
  """
  use Moongate.Macros.Mutations
  use Moongate.Macros.Processes

  @doc """
    Causes the origin of a client event to join
    a stage.
  """
  def arrive(event, stage_module), do: arrive(event, stage_module, "🔮")
  def arrive(event, stage_module, id) do
    event
    |> mutate({:join_stage, stage_module, id})
    |> mutate({:set_target_stage, stage_module, id})
  end

  def stage(module_name), do: stage(module_name, "🔮")
  def stage(module_name, id) do
    name = "#{Moongate.Modules.to_string(module_name)}_#{id}"

    register(:stage, name, [id: name, stage: Moongate.Service.Stages.stage_module(module_name)])
  end
end
