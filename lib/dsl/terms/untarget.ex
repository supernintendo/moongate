defmodule Moongate.DSL.Terms.Untarget do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Untarget, condition}, %CoreEvent{zone: {zone, zone_id}} = event) when is_function(condition) do
      case Core.pid({zone, zone_id}) do
        nil ->
          Core.log({:warning, "No one to untarget (zone does not exist): #{inspect event}"})
          event
        pid ->
          case CoreNetwork.call({:get_members, condition}, pid) do
            {:ok, results} ->
              target_ids = Enum.map(results, &(&1.id))
              event
              |> Map.put(:targets, Enum.filter(results, fn target ->
                !Enum.member?(target_ids, target.id)
              end))
            _ ->
              event
          end
      end
    end
    def call({Untarget, targets}, %CoreEvent{} = event) when is_list(targets) do
      target_ids = Enum.map(targets, &(&1.id))
      event
      |> Map.put(:targets, Enum.filter(event.targets, fn target ->
        !Enum.member?(target_ids, target.id)
      end))
    end
    def call({Untarget, target}, %CoreEvent{} = event) do
      call({Untarget, [target]}, event)
    end
  end
  def untarget(%CoreEvent{zone: nil} = event, condition) when is_function(condition) do
    Core.log({:warning, "No one to target (not within zone): #{inspect event}"})
    event
  end
  def untarget(%CoreEvent{} = event, target_or_targets) do
    {Untarget, target_or_targets}
    |> Queue.push(event)
  end
end
