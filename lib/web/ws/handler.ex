defmodule Moongate.Web.WS.Handler do
  use Moongate.Core.Session
  use Moongate.State, :server

  @behaviour :cowboy_websocket
  @decoder Application.get_env(:moongate, :packets).decoder
  @encoder Application.get_env(:moongate, :packets).encoder
  @session Application.get_env(:moongate, :session)

  def init(req, _) do
    state =
      %{
        origin: new_origin(req),
        zones: []
      }

    {:cowboy_websocket, req, state}
  end

  def terminate(_reason, _req, state) do
    apply(@session, :depart, [state])
    :ok
  end

  def websocket_info({:write, packet}, req, state) do
    {:reply, {:text, @encoder.encode(packet)}, req, state}
  end

  def websocket_handle({:text, content}, req, state) do
    result =
      content
      |> @decoder.decode
      |> cast_to_event(state.origin)
      |> handle_packet(state)
      |> apply_state_mutations(state, @session)

    {:ok, req, result}
  end

  def websocket_handle(_frame, _req, state) do
    {:ok, state}
  end

  defp cast_to_event(body, origin) do
    Map.merge(%Moongate.Event{origin: origin, targets: [origin]}, body)
  end

  defp get_req_ip(req) do
    {ip, _port} = :cowboy_req.peer(req)

    ip
    |> Tuple.to_list
    |> Enum.join(".")
  end

  defp new_origin(req) do
    %Moongate.Origin{
      id: UUID.uuid4(:hex),
      ip: get_req_ip(req),
      port: self,
      protocol: :web
    }
  end
end
