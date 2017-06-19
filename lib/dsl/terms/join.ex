defmodule Moongate.DSL.Terms.Join do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    @factory Application.get_env(:moongate, :packet).factory

    def call({Join, zone_module, zone_name}, %CoreEvent{} = event) do
      pid_name = Core.process_name({zone_module, zone_name})

      for target <- event.targets do
        case CoreNetwork.call({:join, target}, pid_name) do
          :ok ->
            {:grant_access, {:zone, {zone_module, zone_name}}}
            |> CoreNetwork.cast("session_#{target.id}")
            @factory.join({zone_module, zone_name})
            |> CoreNetwork.send_packet(target)
          _ -> nil
        end
      end
      event
    end
  end

  def join(%CoreEvent{} = event, zone_module), do: join(event, zone_module, "$")
  def join(%CoreEvent{} = event, zone_module, zone_name) do
    {Join, zone_module, zone_name}
    |> Queue.push(event)
  end
end

