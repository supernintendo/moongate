defmodule Moongate.Service.Stages do
  use Moongate.Macros.Processes

  @doc """
    Make any neccessary GenServer calls to allow a client
    to join a stage.
  """
  def arrive(event, stage_name) do
    tell_pid!({:arrive, stage_name}, event.origin.events_listener)
    tell!({:arrive, event.origin}, :stage, stage_name)
  end

  @doc """
    Make any neccessary GenServer calls to allow a client
    to join a stage, setting it as target.
  """
  def arrive!(event, stage_name) do
    tell_pid!({:arrive, stage_name, :set_as_target}, event.origin.events_listener)
    tell!({:arrive, event.origin}, :stage, stage_name)
  end

  @doc """
    Make any neccessary GenServer calls to allow a client
    to leave a stage.
  """
  def depart(event) do
    tell_pid!({:depart, event}, event.origin.events_listener)
    tell({:depart, event}, event.to)
  end
end
