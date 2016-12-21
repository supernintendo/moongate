defmodule Moongate.Session do
  @decoder Application.get_env(:moongate, :packets).decoder

  def depart(state) do
    origin = state.origin
    Moongate.Network.cascade({:depart, origin}, "zone")
    Moongate.Network.cascade({:unsubscribe, origin}, "ring")

    :ok
  end

  def handle_packet(%Moongate.Event{body: "init", domain: :request, origin: _origin} = event, _state) do
    event
    |> Moongate.Core.world_apply(:connected)
  end

  def handle_packet(%{domain: {_op, _}} = event, _state) do
    case event do
      %{zone: {_zone_name, _zone_id}, ring: _ring, deed: _deed} ->
        deed_event(event)
      _ ->
        event
    end
  end

  defp deed_event(event) do
    params = @decoder.split_body_params(event.body)
    {zone_name, zone_id} = event.zone

    if event.ring do
      process = Moongate.Ring.Service.process_name({zone_name, zone_id, event.ring})
      Moongate.Network.cast({:deed_event, params, event}, "ring", process)
      event
    end
  end
end
