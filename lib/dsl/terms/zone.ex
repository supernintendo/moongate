defmodule Moongate.DSL.Terms.Zone do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Zone, zone_module, zone_name, zone_params}, %CoreEvent{} = event) do
      process_name = Core.process_name({zone_module, zone_name}, %{prefix: false})
      %{
        id: zone_name,
        name: process_name,
        zone: zone_module,
        zone_params: zone_params
      }
      |> CoreNetwork.register(:zone, process_name)
      event
    end
  end

  def zone(%CoreEvent{} = event, zone_tuple), do: zone(event, zone_tuple, %{})
  def zone(%CoreEvent{} = event, zone_module, zone_params) when is_atom(zone_module) do
    zone(event, {zone_module, "$"}, zone_params)
  end
  def zone(%CoreEvent{} = event, {zone_module, zone_name}, zone_params) do
    {Zone, zone_module, zone_name, zone_params}
    |> Queue.push(event)
  end
end
