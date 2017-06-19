defmodule Moongate.DSL.Terms.Save do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Save, zone_module, zone_name}, %CoreEvent{} = event) do
      pid_name = Core.process_name({zone_module, zone_name})

      CoreNetwork.call({:save, event}, pid_name)
      event
    end
  end

  def save(%CoreEvent{} = event, zone_module), do: save(event, zone_module, "$")
  def save(%CoreEvent{} = event, zone_module, zone_name) do
    {Save, zone_module, zone_name}
    |> Queue.push(event)
  end
  def save(%CoreEvent{zone: {zone_module, zone_name}} = event) do
    save(event, zone_module, zone_name)
  end
end
