defmodule Moongate.Session.Mutations do
  def mutate({:join_zone, zone_name, zone_id}, event, state) do
    for target <- event.targets do
      Moongate.Zone.Service.arrive(target, zone_name, zone_id)
    end

    {
      {:zones, state.zones ++ [Moongate.Zone.Service.process_name(zone_name, zone_id)]},
      event
    }
  end
end
