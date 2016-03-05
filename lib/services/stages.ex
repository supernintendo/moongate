defmodule Moongate.Service.Stages do
  use Moongate.Macros.Processes

  @doc """
    Make any neccessary GenServer calls to allow a client
    to join a stage.
  """
  def arrive(event, stage_name) do
    tell_pid(event.origin.events_listener, {:arrive, stage_name})
    tell_sync(:stage, stage_name, {:arrive, event.origin})
  end

  @doc """
    Make any neccessary GenServer calls to allow a client
    to join a stage, setting it as target.
  """
  def arrive!(event, stage_name) do
    tell_pid(event.origin.events_listener, {:arrive, stage_name, :set_as_target})
    tell_sync(:stage, stage_name, {:arrive, event.origin})
  end

  @doc """
    Make any neccessary GenServer calls to allow a client
    to leave a stage.
  """
  def depart(event) do
    tell_pid(event.origin.events_listener, {:depart, event})
    tell_async(event.to, {:depart, event})
  end
end
