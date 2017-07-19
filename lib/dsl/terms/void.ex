defmodule Moongate.DSL.Terms.Void do
  alias Moongate.{
    CoreEvent,
    DSLQueue
  }

  defmodule Dispatcher do
    def call(Void, %CoreEvent{} = event) do
      event
      |> Map.put(:void, true)
    end
  end

  def void(%CoreEvent{} = event) do
    Void
    |> DSLQueue.push(event)
  end
end
