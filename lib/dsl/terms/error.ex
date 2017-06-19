defmodule Moongate.DSL.Terms.Error do
  alias Moongate.{
    Core,
    CoreEvent,
    DSL.Queue
  }

  defmodule Dispatcher do
    require Logger

    def call({Error, message}, %CoreEvent{} = event) do
      Core.log({:error, message})
      event
      |> Map.put(:void, true)
    end
  end

  def error(%CoreEvent{} = event, message) do
    {Error, message}
    |> Queue.push(event)
  end
end
