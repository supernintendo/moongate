defmodule Moongate.DSL.Terms.Attach do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    DSLQueue
  }

  defmodule Dispatcher do
    @factory Application.get_env(:moongate, :packet).factory

    def call({Attach, key, value}, %CoreEvent{} = event) do
      @factory.attach(key, value)
      |> CoreNetwork.send_packet(event.targets)
      event
    end
  end

  def attach(%CoreEvent{} = event, key, value) do
    {Attach, key, value}
    |> DSLQueue.push(event)
  end
end
