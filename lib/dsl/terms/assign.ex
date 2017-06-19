defmodule Moongate.DSL.Terms.Assign do
  alias Moongate.{
    CoreEvent,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Assign, callback}, %CoreEvent{assigns: assigns} = event) when is_function(callback) do
      struct(event, assigns: Map.merge(assigns, callback.(event)))
    end
    def call({Assign, map}, %CoreEvent{assigns: assigns} = event) when is_map(map) do
      struct(event, assigns: Map.merge(assigns, map))
    end
    def call({Assign, key, callback}, %CoreEvent{assigns: assigns} = event) when is_function(callback) do
      struct(event, assigns: Map.put(assigns, key, callback.(event)))
    end
    def call({Assign, key, value}, %CoreEvent{assigns: assigns} = event) do
      struct(event, assigns: Map.put(assigns, key, value))
    end
  end

  def assign(%CoreEvent{} = event, changes)
  when is_map(changes) or is_list(changes) do
    {Assign, changes}
    |> Queue.push(event)
  end
  def assign(%CoreEvent{} = event, key, value) do
    {Assign, key, value}
    |> Queue.push(event)
  end
end
