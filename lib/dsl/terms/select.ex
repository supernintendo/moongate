defmodule Moongate.DSL.Terms.Select do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreOrigin,
    CoreNetwork,
    DSLQueue
  }

  defmodule Dispatcher do
    def call({Select, :void}, %CoreEvent{} = event) do
      %{event | selected: nil}
    end

    def call({Select, ring, condition}, %CoreEvent{zone: {zone, zone_id}} = event)
    when is_function(condition) do
      case Core.pid({{zone, zone_id}, ring}) do
        nil ->
          event
        pid ->
          results = get_member_indices(condition, pid)
          %{event | selected: {ring, results}}
      end
    end

    defp get_member_indices(condition, ring_pid) do
      case CoreNetwork.call({:get_member_indices, condition}, ring_pid) do
        {:ok, members} -> members
        _ -> []
      end
    end
  end

  def select(event, :void), do: DSLQueue.push({Select, :void}, event)
  def select(%CoreEvent{zone: {_zone, _zone_id}, ring: ring} = event, condition) do
    select(event, ring, condition)
  end
  def select(%CoreEvent{zone: {_zone, _zone_id}} = event, ring, condition) when is_function(condition) do
    {Select, ring, condition}
    |> DSLQueue.push(event)
  end
  def select(%CoreEvent{zone: {_zone, _zone_id}} = event, ring, %CoreOrigin{} = origin) do
    select(event, ring, &(&1[:__origin_id__] && &1[:__origin_id__] == origin.id))
  end
end
