defmodule Moongate.Zone.Service do
  @moduledoc """
    Provides functions related to working with zones.
  """
  use Moongate.Core

  @doc """
    Make any neccessary GenServer calls to allow a client
    to join a zone.
    """
  def arrive(origin, zone_module, name) do
    process_name = Moongate.Zone.Service.zone_process_name(zone_module, name)
    ask({:arrive, origin}, process_name)
  end

  @doc """
    Make any neccessary GenServer calls to allow a client
    to leave a zone.
  """
  def depart(event) do
    tell({:depart, event}, event.to)
  end

  def zone_module(module_name) do
    [Moongate.Utility.get_world
     |> String.capitalize
     |> String.replace("-", "_")
     |> Mix.Utils.camelize
     |> String.to_atom, Zone, module_name]
    |> Module.safe_concat
  end

  def zone_process_name(zone_module, id) do
    "zone_#{Moongate.Utility.module_to_string(zone_module)}_#{id}"
  end
end
