defmodule Moongate.DSL.Terms.Trigger do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSLQueue
  }

  defmodule Dispatcher do
    def call({Trigger, {{zone, zone_id}, {ring, rule}}, handler_name}, %CoreEvent{} = event) do
      call({Trigger, {{zone, zone_id}, ring}, handler_name}, struct(event, rule: rule))
      event
    end
    def call({Trigger, scope, handler_name}, %CoreEvent{} = event) do
      case Core.pid(scope) do
        nil ->
          event
        pid ->
          {:trigger, handler_name, struct(event, queue: [], step: 0)}
          |> CoreNetwork.cast(pid)
          event
      end
    end
  end

  def trigger(%CoreEvent{} = event, {{zone, zone_id}, {ring, rule}}, handler_name)
      when is_atom(zone)
      when is_bitstring(zone_id)
      when is_atom(ring)
      when is_atom(rule)
      when is_bitstring(handler_name) do
    {Trigger, {{zone, zone_id}, {ring, rule}}, handler_name}
    |> DSLQueue.push(event)
  end
  def trigger(%CoreEvent{} = event, {{zone, zone_id}, {ring, rule}}, handler_name)
      when is_atom(zone)
      when is_bitstring(zone_id)
      when is_atom(ring)
      when is_atom(rule)
      when is_bitstring(handler_name) do
    {Trigger, {{zone, zone_id}, {ring, rule}}, handler_name}
    |> DSLQueue.push(event)
  end
  def trigger(%CoreEvent{} = event, {{zone, zone_id}, ring}, handler_name)
      when is_atom(zone)
      when is_bitstring(zone_id)
      when is_atom(ring)
      when is_bitstring(handler_name) do
    {Trigger, {{zone, zone_id}, ring}, handler_name}
    |> DSLQueue.push(event)
  end
  def trigger(%CoreEvent{} = event, {zone, zone_id}, handler_name)
      when is_atom(zone)
      when is_bitstring(zone_id)
      when is_bitstring(handler_name) do
    {Trigger, {zone, zone_id}, handler_name}
    |> DSLQueue.push(event)
  end
  def trigger(%CoreEvent{} = event, zone, handler_name)
      when is_atom(zone)
      when is_bitstring(handler_name) do
    trigger(event, {zone, "$"}, handler_name)
  end
end

