defmodule Moongate.DSL.Terms.Leave do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSLQueue
  }

  defmodule Dispatcher do
    @factory Application.get_env(:moongate, :packet).factory

    def call({Leave, zone_module, zone_name}, %CoreEvent{} = event) do
      pid_name = Core.process_name({zone_module, zone_name})

      for target <- event.targets do
        case CoreNetwork.call({:leave, target}, pid_name) do
          :ok ->
            {:revoke_access, {:zone, {zone_module, zone_name}}}
            |> CoreNetwork.cast("session_#{target.id}")
            @factory.leave({zone_module, zone_name})
            |> CoreNetwork.send_packet(target)
          _ -> nil
        end
      end
      event
    end
  end

  def leave(%CoreEvent{} = event, zone_module), do: leave(event, zone_module, "$")
  def leave(%CoreEvent{} = event, zone_module, zone_name) do
    {Leave, zone_module, zone_name}
    |> DSLQueue.push(event)
  end
  def leave(%CoreEvent{zone: {zone_module, zone_name}} = event) do
    leave(event, zone_module, zone_name)
  end
end
