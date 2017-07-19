defmodule Moongate.DSL.Terms.Create do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    CoreUtility,
    DSLQueue
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
        results =
          targets
          |> Enum.map(&{:add_member, Map.merge(%{__origin_id__: &1.id}, params)})
          |> Enum.map(&(CoreNetwork.call(&1, "ring_#{ring}__#{zone}_#{zone_id}")))
          |> Enum.map(&(elem(&1, 1)))
          |> Enum.filter(&(&1))

        struct(event, selected: {ring, results})
      else
        case CoreNetwork.call({:add_member, params}, "ring_#{ring}__#{zone}_#{zone_id}") do
          {:ok, index} ->
            struct(event, selected: {ring, [index]})
          _ ->
            event
        end
      end
    end
  end

  def create(%CoreEvent{zone: {_zone, _zone_id}} = event, ring, params) when is_atom(ring) do
    {Create, ring, params}
    |> DSLQueue.push(event)
  end
  def create(%CoreEvent{} = event, ring, params) when is_atom(ring) do
    event
    |> Map.put(:zone, {event.zone, "$"})
    |> create(ring, params)
  end
  def create(%CoreEvent{} = event, ring), do: create(event, ring, %{})
end
