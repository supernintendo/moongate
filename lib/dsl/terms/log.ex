defmodule Moongate.DSL.Terms.Log do
  alias Moongate.{
    Core,
    CoreEvent,
    DSLQueue
  }

  defmodule Dispatcher do
    require Logger

    def call({Log, message}, %CoreEvent{} = event) do
      Core.log({:info, message})
      event
    end
  end

  def log(%CoreEvent{} = event, message) do
    {Log, message}
    |> DSLQueue.push(event)
  end
end
