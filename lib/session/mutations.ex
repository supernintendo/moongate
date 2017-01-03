defmodule Moongate.SessionMutations do
  def mutate({:join_zone, zone_name, zone_id}, event, state) do
    for target <- event.targets do
      Moongate.ZoneService.arrive(target, zone_name, zone_id)
    end

    {
      {:zones, state.zones ++ [Moongate.ZoneService.process_name(zone_name, zone_id)]},
      event
    }
  end
end
