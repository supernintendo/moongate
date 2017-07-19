defmodule Moongate.DSLQueue do
  alias Moongate.CoreEvent

  def push(term, %CoreEvent{queue: queue} = event) do
    event
    |> Map.merge(%{
      queue: queue ++ [{term, event.step}],
      step: event.step + 1
    })
  end
end
