defmodule Moongate.DSL.Terms.Void do
  alias Moongate.{
    CoreEvent,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call(Void, %CoreEvent{} = event) do
      event
      |> Map.put(:void, true)
    end
  end

  def void(%CoreEvent{} = event) do
    Void
    |> Queue.push(event)
  end
end
