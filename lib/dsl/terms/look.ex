defmodule Moongate.DSL.Terms.Look do
  alias Moongate.{
    CoreEvent,
    DSL.Queue
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
      inspect(event)
      event
    end
  end

  def look(%CoreEvent{} = event, label) do
    {Look, label}
    |> Queue.push(event)
  end
  def look(%CoreEvent{} = event) do
    Look
    |> Queue.push(event)
  end
end
