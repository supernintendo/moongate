defmodule Moongate.RingMutations do
  def mutate({:add_member, params}, event, state) do
    attributes =
      params
      |> Enum.filter(fn {key, _value} -> Map.has_key?(state.attributes, key) end)
      |> Enum.into(%{__index: state.index})

    member =
      Moongate.RingService.member_defaults(state.attributes)
      |> Map.merge(attributes)

    for subscriber <- state.subscribers do
      %Moongate.CorePacket{
        body: Moongate.RingService.encode(member, state.attributes),
        domain: {:add, :ring},
        ring: {state.name, state.index},
        zone: {state.zone, state.zone_id}
      }
      |> Moongate.CoreNetwork.send_packet(subscriber)
    end

    {[{:index, state.index + 1}, {:members, state.members ++ [member]}], event}
  end

  def mutate({:add_subscriber, origin}, event, state) do
    for member <- state.members do
      %Moongate.CorePacket{
        body: Moongate.RingService.encode(member, state.attributes),
        domain: {:add, :ring},
        ring: {state.name, member.__index},
        zone: {state.zone, state.zone_id}
      }
      |> Moongate.CoreNetwork.send_packet(origin)
    end

    {{:subscribers, state.subscribers ++ [origin]}, event}
  end

  def mutate({:remove_subscriber, origin}, event, state) do
    member = Enum.find(state.members, fn(member) ->
      Map.has_key?(member, :origin) && member.origin.id == origin.id
    end)
    subscribers = Enum.filter(state.subscribers, &(&1.id != origin.id))

    if member do
      for subscriber <- subscribers do
        %Moongate.CorePacket{
          domain: {:remove, :ring},
          ring: {state.name, member.__index},
          zone: {state.zone, state.zone_id}
        }
        |> Moongate.CoreNetwork.send_packet(subscriber)
      end
    end

    {[
      {:members, Enum.filter(state.members, &(&1.origin.id != origin.id))},
      {:subscribers, subscribers}
    ], event}
  end

  def mutate({:set, params}, event, state) do
    members =
      state.members
      |> Enum.map(fn(member) ->
        if member_is_targeted?(member, event.targets) do
          updated_params = Moongate.RingService.member_params(params, state.attributes)
          updated_member = Map.merge(member, updated_params)

          for subscriber <- state.subscribers do
            %Moongate.CorePacket{
              body: Moongate.RingService.encode(updated_params, state.attributes),
              domain: {:set, :ring},
              ring: {state.name, member.__index},
              zone: {state.zone, state.zone_id}
            }
            |> Moongate.CoreNetwork.send_packet(subscriber)
          end
          updated_member
        else
          member
        end
      end)

    {{:members, members}, event}
  end

  def mutate({:target, value}, event, state) when is_function(value) do
    targets =
      state.members
      |> Enum.filter(value)

    {nil, %{event | targets: event.targets ++ targets}}
  end

  defp member_is_targeted?(member, targets) do
    Enum.any?(targets, fn(target) ->
      Map.has_key?(target, :__index) &&
      target.__index == member.__index
    end)
  end
end
