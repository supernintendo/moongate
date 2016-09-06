defmodule Moongate.Stage.Service do
  @moduledoc """
    Provides functions related to working with stages.
  """
  use Moongate.OS

  @doc """
    Make any neccessary GenServer calls to allow a client
    to join a stage.
    """
  def arrive(origin, stage_module, name) do
    process_name = Moongate.Stage.Service.stage_process_name(stage_module, name)
    ask({:arrive, origin}, process_name)
  end

  @doc """
    Make any neccessary GenServer calls to allow a client
    to leave a stage.
  """
  def depart(event) do
    tell({:depart, event}, event.to)
  end

  def stage_module(module_name) do
    [Moongate.World.Service.get_world
     |> String.capitalize
     |> String.replace("-", "_")
     |> Mix.Utils.camelize
     |> String.to_atom, Stage, module_name]
    |> Module.safe_concat
  end

  def stage_process_name(stage_module, id) do
    "stage_#{Moongate.Modules.to_string(stage_module)}_#{id}"
  end
end
