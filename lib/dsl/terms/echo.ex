defmodule Moongate.DSL.Terms.Echo do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    CoreTypes,
    DSLQueue
  }

  defmodule Dispatcher do
    @packet Application.get_env(:moongate, :packet)

    def call({Echo, callback}, %CoreEvent{} = event) when is_function(callback) do
      callback.(event)
      |> CoreTypes.cast(String)
      |> @packet.factory.echo()
      |> CoreNetwork.send_packet(event.targets)
      event
    end
    def call({Echo, message}, %CoreEvent{} = event) do
      @packet.factory.echo(message)
      |> CoreNetwork.send_packet(event.targets)
      event
    end
  end

  def echo(%CoreEvent{} = event, message)
  when is_bitstring(message)
  or is_function(message) do
    {Echo, message}
    |> DSLQueue.push(event)
  end
end
