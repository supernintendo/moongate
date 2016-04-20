defmodule Moongate.Service.Stages do
  @moduledoc """
    Provides functions related to working with stages.
  """
  use Moongate.Macros.Processes

  @doc """
    Make any neccessary GenServer calls to allow a client
    to join a stage.
  """
  def arrive(origin, stage_name) do
    tell!({:arrive, origin}, :stage, stage_name)
  end

  @doc """
    Make any neccessary GenServer calls to allow a client
    to leave a stage.
  """
  def depart(event) do
    tell({:depart, event}, event.to)
  end
end
