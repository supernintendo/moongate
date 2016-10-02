defmodule Moongate.Session.Mutations do
  @moduledoc """
    Provides functions which mutate the state of an
    event process.
  """
  def mutation({:join_zone, zone_name, id}, event, state) do
    Moongate.Zone.Service.arrive(event.origin, zone_name, id)

    {:zones, state.zones ++ [Moongate.Zone.Service.zone_process_name(zone_name, id)]}
  end

  @doc """
    Remove a zone from the joined zones list.
  """
  def mutation({:leave_from, _origin}, event, state) do
    {:zones, Enum.filter(state.zones, &(&1 != event.from)) }
  end

  @doc """
    Set a zone as the target zone, causing incoming messages
    to be sent to that zone.
  """
  def mutation({:set_target_zone, zone_module, id}, _event, _state) do
    {:target_zone, Moongate.Zone.Service.zone_process_name(zone_module, id)}
  end
end
