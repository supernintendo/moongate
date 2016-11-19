defmodule Moongate.Worlds do
  @moduledoc """
    Provides macros for the World module of a
    Moongate world (the World module is the
    entry point of the world).
  """
  use Moongate.Core
  use Moongate.State

  @doc """
    Causes the origin of a client event to join
    a zone.
  """
  def arrive(event, zone_module), do: arrive(event, zone_module, "$")
  def arrive(event, zone_module, id) do
    event
    |> mutate({:join_zone, zone_module, id})
    |> mutate({:set_target_zone, zone_module, id})
  end

  def zone(module_name), do: zone(module_name, "$")
  def zone(module_name, id) do
    name = "#{Moongate.Utility.module_to_string(module_name)}_#{id}"

    register(:zone, name, [
      id: name,
      zone: Moongate.Zone.Service.zone_module(module_name)
    ])
  end
end
