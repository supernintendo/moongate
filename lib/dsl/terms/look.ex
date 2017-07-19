defmodule Moongate.DSL.Terms.Look do
  alias Moongate.{
    CoreEvent,
    DSLQueue
  }

  defmodule Dispatcher do
    require Logger

    def call({Look, label}, %CoreEvent{} = event) do
      ~s(
#{label}:
#{inspect event}

)
      |> String.trim()
      |> IO.puts()
      event
    end
    def call(Look, %CoreEvent{} = event) do
      IO.puts "#{inspect event}"
      event
    end
  end

  def look(%CoreEvent{} = event, label) do
    {Look, label}
    |> DSLQueue.push(event)
  end
  def look(%CoreEvent{} = event) do
    Look
    |> DSLQueue.push(event)
  end
end
