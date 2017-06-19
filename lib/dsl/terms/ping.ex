defmodule Moongate.DSL.Terms.Ping do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    @factory Application.get_env(:moongate, :packet).factory

    def call(Ping, %CoreEvent{} = event) do
      @factory.ping()
      |> CoreNetwork.send_packet(event.targets)
      event
    end
  end

  def ping(%CoreEvent{} = event) do
    Ping
    |> Queue.push(event)
  end
end
