defmodule Moongate.DSL.Terms.Function do
  alias Moongate.{
    CoreEvent,
    DSLQueue
  }

  defmodule Dispatcher do
    def call({Function, function, args}, %CoreEvent{} = event) do
      apply(function, [event] ++ args)
    end
  end

  def function(%CoreEvent{} = event, function) when is_function(function) do
    function(event, function, [])
  end
  def function(%CoreEvent{} = event, function, args) when is_function(function) do
    {Function, function, args}
    |> DSLQueue.push(event)
  end
end
