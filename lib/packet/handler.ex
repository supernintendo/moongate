defmodule Moongate.PacketHandler do
  alias Moongate.{
    Core,
    CoreEvent
  }

  @packet Application.get_env(:moongate, :packet)
  @prohibited_handlers [
    "connect",
    "disconnect",
    "leave",
    "join",
    "start"
  ]

  def handle_packet(event, state) do
    case event do
      %CoreEvent{zone: {_zone_module, _zone_name}, ring: ring_module, rule: rule_module}
      when not is_nil(ring_module)
      and not is_nil(rule_module) ->
        packet_event(event, rule_module, state)
      %CoreEvent{zone: {_zone_module, _zone_name}, ring: ring_module}
      when not is_nil(ring_module) ->
        packet_event(event, ring_module, state)
      %CoreEvent{zone: {zone_module, _zone_name}} ->
        packet_event(event, zone_module, state)
      %CoreEvent{zone: zone_module} when not is_nil(zone_module) ->
        handle_packet(%CoreEvent{event | zone: {zone_module, "$"}}, state)
      %CoreEvent{} ->
        packet_event(event, "Game", state)
      _ ->
        nil
    end
  end

  def packet_event(%CoreEvent{handler: handler}, _module, _state) when is_nil(handler), do: nil
  def packet_event(%CoreEvent{handler: handler} = event, _module, state) do
    cond do
      Enum.member?(@prohibited_handlers, handler) ->
        reject_packet(event, ":#{handler} is a built-in event")
      !has_access?(event, state) ->
        reject_packet(event, "session does not have access to zone")
      true ->
        Core.log({:packet, event})
        event
        |> struct(targets: event.targets ++ [event.origin])
        |> attach_packet_arguments()
        |> Core.trigger(handler)
        |> dispatch()
    end
  end

  defp dispatch(nil), do: nil
  defp dispatch(event), do: Core.dispatch(event)

  defp attach_packet_arguments(%{body: body} = event) do
    case @packet.decoder.split_body_params(body) do
      arguments when is_tuple(arguments) ->
        %{event | arguments: arguments, body: ""}
      nil ->
        event
    end
  end

  defp has_access?(%CoreEvent{zone: {zone_module, zone_name}}, state) do
    Enum.member?(state.access, {:zone, {zone_module, zone_name}})
  end
  defp has_access?(_event, _state), do: true

  defp reject_packet(event, reason) do
    Core.log({:warning, "Packet rejected (#{reason}): #{inspect event}"})
    nil
  end
end
