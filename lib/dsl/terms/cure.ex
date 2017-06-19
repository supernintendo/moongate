defmodule Moongate.DSL.Terms.Cure do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Cure, key}, %CoreEvent{
      rule: rule,
      selected: {ring, member_indices},
      zone: {zone, zone_id}
    } = event) do
      case Core.pid({{zone, zone_id}, ring}) do
        nil ->
          event
        pid ->
          {:cure_members, member_indices, rule, key}
          |> CoreNetwork.call(pid)
          event
      end
    end
    def call({Cure, _changes}, event), do: event
  end

  def cure(%CoreEvent{ring: nil} = event, _, _) do
    Core.log({:warning, "Cure not queued (not within ring): #{inspect event}"})
    event
  end
  def cure(%CoreEvent{rule: nil} = event, _, _) do
    Core.log({:warning, "Cure not queued (not within rule): #{inspect event}"})
    event
  end
  def cure(%CoreEvent{ring: _ring, zone: {_zone, _zone_id}} = event, key) do
    {Cure, key}
    |> Queue.push(event)
  end
end
