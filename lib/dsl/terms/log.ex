defmodule Moongate.DSL.Terms.Log do
  alias Moongate.{
    Core,
    CoreEvent,
    DSL.Queue
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
    |> Queue.push(event)
  end
end
