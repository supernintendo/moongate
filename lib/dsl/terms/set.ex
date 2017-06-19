defmodule Moongate.DSL.Terms.Set do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Set, callback}, %CoreEvent{
      selected: {_ring, _member_indices},
      zone: {_zone, _zone_id}} = event)
        when is_function(callback) do
      changes = apply(callback, [event])
      call({Set, changes}, event)
    end
    def call({Set, changes}, %CoreEvent{selected: {ring, member_indices}, zone: {zone, zone_id}} = event) do
      case Core.pid({{zone, zone_id}, ring}) do
        nil ->
          event
        pid ->
          {:set_on_members, member_indices, changes}
          |> CoreNetwork.call(pid)
          event
      end
    end
    def call({Set, _changes}, event), do: event
  end

  def set(%CoreEvent{ring: _ring, zone: {_zone, _zone_id}} = event, callback) when is_function(callback) do
    {Set, callback}
    |> Queue.push(event)
  end
  def set(%CoreEvent{ring: _ring, zone: {_zone, _zone_id}} = event, changeset) when is_map(changeset) do
    {Set, changeset}
    |> Queue.push(event)
  end
  def set(%CoreEvent{ring: _ring, zone: {_zone, _zone_id}} = event, key, value) do
    set(event, %{key => value})
  end
  def set(%CoreEvent{ring: nil} = event) do
    Core.log({:warning, "Set not queued (not within ring): #{inspect event}"}).
    event
  end
end
