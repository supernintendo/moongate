defmodule Moongate.DSL.Terms.Target do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreNetwork,
    DSLQueue
  }

  defmodule Dispatcher do
    def call({Target, condition}, %CoreEvent{zone: {zone, zone_id}} = event) when is_function(condition) do
      case Core.pid({zone, zone_id}) do
        nil ->
          Core.log({:warning, "No one to target (zone does not exist): #{inspect event}"})
          event
        pid ->
          case CoreNetwork.call({:get_members, condition}, pid) do
            {:ok, results} ->
              event
              |> Map.put(:targets, Enum.uniq_by(event.targets ++ results, &(&1.id)))
            _ ->
              event
          end
      end
    end
    def call({Target, targets}, %CoreEvent{} = event) when is_list(targets) do
      event
      |> Map.put(:targets, Enum.uniq_by(event.targets ++ targets, &(&1.id)))
    end
    def call({Target, target}, %CoreEvent{} = event) do
      call({Target, [target]}, event)
    end
  end

  def target(%CoreEvent{zone: nil} = event, condition) when is_function(condition) do
    Core.log({:warning, "No one to target (not within zone): #{inspect event}"})
    event
  end
  def target(%CoreEvent{} = event, target_or_targets) do
    {Target, target_or_targets}
    |> DSLQueue.push(event)
  end
end
