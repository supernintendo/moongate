defmodule Moongate.DSL.Terms.Peek do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Peek, opts}, %CoreEvent{selected: {ring, member_indices}, zone: {zone, zone_id}} = event) do
      case Core.pid({{zone, zone_id}, ring}) do
        nil ->
          event
        pid ->
          case CoreNetwork.call({:get_members, member_indices, opts}, pid) do
            {:ok, members} ->
              %{ event | peek: {ring, members} }
            _ ->
              event
          end
      end
    end
    def call({Peek, _opts}, event), do: event
  end

  def peek(%CoreEvent{} = event, :raw) do
    {Peek, %{ raw: true }}
    |> Queue.push(event)
  end
  def peek(%CoreEvent{} = event) do
    {Peek, %{}}
    |> Queue.push(event)
  end
end
