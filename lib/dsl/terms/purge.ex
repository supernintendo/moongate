defmodule Moongate.DSL.Terms.Purge do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    CoreOrigin,
    CoreUtility,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Purge, ring, condition}, %CoreEvent{zone: {zone, zone_id}} = event) do
      ring = CoreUtility.atom_to_string(ring)
      zone = CoreUtility.atom_to_string(zone)
      CoreNetwork.call({:remove_members, condition}, "ring_#{ring}@#{zone}_#{zone_id}")
      event
    end
  end

  def purge(%CoreEvent{zone: {_zone, _zone_id}} = event, ring, condition) when is_atom(ring) and is_function(condition) do
    {Purge, ring, condition}
    |> Queue.push(event)
  end
  def purge(%CoreEvent{} = event, ring, condition) when is_atom(ring) and is_function(condition) do
    event
    |> Map.put(:zone, {event.zone, "$"})
    |> purge(ring, condition)
  end
  def purge(%CoreEvent{} = event, ring, %CoreOrigin{} = origin) when is_atom(ring) do
    purge(event, ring, &(&1[:__origin_id__] && &1[:__origin_id__] == origin.id))
  end
  def purge(%CoreEvent{} = event, ring) when is_atom(ring) do
    purge(event, ring, fn _ -> true end)
  end
end
