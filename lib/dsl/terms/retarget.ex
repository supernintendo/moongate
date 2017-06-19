defmodule Moongate.DSL.Terms.Retarget do
  alias Moongate.{
    CoreEvent,
    DSL.Queue
  }

  def retarget(%CoreEvent{} = event, target_arg) do
    [{Untarget, &(&1)}, {Target, target_arg}]
    |> Enum.reduce(event, fn term, acc ->
      Queue.push(term, acc)
    end)
  end
end
