defmodule Moongate.DSL.Terms.Create do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    CoreUtility,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Create, ring, callback}, %CoreEvent{
      targets: _targets,
      zone: {_zone, _zone_id}
    } = event)
        when is_function(callback) do
      params = apply(callback, [event])
      call({Create, ring, params}, event)
    end
    def call({Create, ring, params}, %CoreEvent{targets: targets, zone: {zone, zone_id}} = event) do
      ring = CoreUtility.atom_to_string(ring)
      zone = CoreUtility.atom_to_string(zone)

      if length(targets) > 0 do
        for target <- targets do
          {:add_member, Map.merge(%{__origin_id__: target.id}, params)}
          |> CoreNetwork.call("ring_#{ring}@#{zone}_#{zone_id}")
        end
      else
        {:add_member, params}
        |> CoreNetwork.call("ring_#{ring}@#{zone}_#{zone_id}")
      end

      event
    end
  end

  def create(%CoreEvent{zone: {_zone, _zone_id}} = event, ring, params) when is_atom(ring) do
    {Create, ring, params}
    |> Queue.push(event)
  end
  def create(%CoreEvent{} = event, ring, params) when is_atom(ring) do
    event
    |> Map.put(:zone, {event.zone, "$"})
    |> create(ring, params)
  end
  def create(%CoreEvent{} = event, ring), do: create(event, ring, %{})
end
