defmodule Moongate.DSL.Terms.Morph do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }
  import Exmorph

  defmodule Dispatcher do
    def call({Morph, key, callback}, %CoreEvent{
      rule: _rule,
      selected: {_ring, _member_indices},
      zone: {_zone, _zone_id}
    } = event)
        when is_function(callback) do
      result = apply(callback, [event])
      call({Morph, key, result}, event)
    end
    def call({Morph, key, %Exmorph.Tween{} = tween}, %CoreEvent{
      rule: rule,
      selected: {ring, member_indices},
      zone: {zone, zone_id}
    } = event) do
      case Core.pid({{zone, zone_id}, ring}) do
        nil ->
          event
        pid ->
          {:morph_members, member_indices, rule, key, tween}
          |> CoreNetwork.call(pid)
          event
      end
    end
    def call({Morph, _changes}, event), do: event
  end

  def morph(%CoreEvent{ring: nil} = event, _, _, _) do
    Core.log({:warning, "Morph not queued (not within ring): #{inspect event}"})
    event
  end
  def morph(%CoreEvent{
    ring: _ring,
    zone: {_zone, _zone_id}
  } = event, key, {operation, change}, {duration, time_unit}) do
    case operation do
      :sub ->
        morph(event, key, ~t(from 0 add -#{change} every #{duration}#{time_unit} over infinity))
      :add ->
        morph(event, key, ~t(from 0 add #{change} every #{duration}#{time_unit} over infinity))
      _ ->
        Core.log({:warning, "Morph not queued (invalid operation): #{inspect operation}"})
        event
    end
  end
  def morph(%CoreEvent{rule: nil} = event, _, _, _) do
    Core.log({:warning, "Morph not queued (not within rule): #{inspect event}"})
    event
  end
  def morph(%CoreEvent{
    ring: _ring,
    zone: {_zone, _zone_id}
  } = event, key, %Exmorph.Tween{} = tween) do
    {Morph, key, tween}
    |> Queue.push(event)
  end
  def morph(%CoreEvent{
    ring: _ring,
    zone: {_zone, _zone_id}
  } = event, key, callback) when is_function(callback) do
    {Morph, key, callback}
    |> Queue.push(event)
  end
end
