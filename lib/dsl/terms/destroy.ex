defmodule Moongate.DSL.Terms.Destroy do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSLQueue
  }

  defmodule Dispatcher do
    def call(Destroy, %CoreEvent{selected: {ring, member_indices}, zone: {zone, zone_id}} = event) do
      case Core.pid({{zone, zone_id}, ring}) do
        nil ->
          event
        pid ->
          {:remove_members, member_indices}
          |> CoreNetwork.call(pid)
          event
      end
    end
    def call(Destroy, event), do: event
  end

  def destroy(%CoreEvent{zone: {_zone, _zone_id}} = event) do
    Destroy
    |> DSLQueue.push(event)
  end
  def destroy(%CoreEvent{zone: nil} = event) do
    Core.log({:warning, "Destroy not queued (not within zone): #{inspect event}"}).
    event
  end
end
