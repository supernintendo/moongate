defmodule Moongate.DSL.Terms.Warn do
  alias Moongate.{
    Core,
    CoreEvent,
    DSLQueue
  }

  defmodule Dispatcher do
    require Logger

    def call({Warn, message}, %CoreEvent{} = event) do
      Core.log({:warning, message})
      event
    end
  end

  def warn(%CoreEvent{} = event, message) do
    {Warn, message}
    |> DSLQueue.push(event)
  end
end
