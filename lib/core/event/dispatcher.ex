defmodule Moongate.CoreDispatcher do
  alias Moongate.CoreEvent
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def handle_cast(%CoreEvent{} = event, state) do
    process_event(event)
    {:noreply, state}
  end

  defp process_event(%CoreEvent{} = event) do
    event.queue
    |> Enum.sort(&sort_by_index/2)
    |> Enum.reduce(event, &handle_term/2)
  end

  defp handle_term({_term, _index}, %{void: true} = acc), do: acc
  defp handle_term({term, index}, acc) when is_tuple(term) do
    Module.safe_concat([Moongate.DSL.Terms, elem(term, 0), Dispatcher])
    |> apply(:call, [term, acc])
    |> filter_term(index)
  end
  defp handle_term({term, index}, acc) do
    Module.safe_concat([Moongate.DSL.Terms, term, Dispatcher])
    |> apply(:call, [term, acc])
    |> filter_term(index)
  end

  defp filter_term(%CoreEvent{} = event, dropped_index) do
    event
    |> Map.put(:queue, Enum.filter(event.queue, fn {_term, index} ->
      index != dropped_index
    end))
  end

  defp sort_by_index({_term_a, index_a}, {_term_b, index_b}) do
    index_b > index_a
  end
end
