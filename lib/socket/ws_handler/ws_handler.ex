defmodule Moongate.Socket.WSHandler do
  alias Moongate.{
    CoreNetwork,
    CoreSession,
    SocketState
  }

  @behaviour :cowboy_websocket
  @packet Application.get_env(:moongate, :packet)

  def init(req, %SocketState{}) do
    origin = CoreNetwork.new_origin(self(), get_req_ip(req), :web)
    %CoreSession{
      origin: origin
    }
    |> CoreNetwork.register(:session, origin.id)

    {:cowboy_websocket, req, %{origin_id: origin.id}}
  end

  def terminate(_reason, _req, state) do
    notify_terminated(state)
    :ok
  end

  def websocket_info({:write, packet}, req, state) do
    {:reply, {:text, @packet.encoder.encode(packet)}, req, state}
  end

  def websocket_handle({:text, data}, req, state) do
    {:client_packet, @packet.decoder.decode(data)}
    |> CoreNetwork.cast("session_#{state.origin_id}")

    {:ok, req, state}
  end

  def websocket_handle(_frame, _req, state) do
    {:ok, state}
  end

  defp get_req_ip(req) do
    {ip, _port} = :cowboy_req.peer(req)

    ip
    |> Tuple.to_list
    |> Enum.join(".")
  end

  defp notify_terminated(%{origin_id: origin_id}) when not is_nil(origin_id) do
    {:ok, pid} = CoreNetwork.call(:terminated, "session_#{origin_id}")
    CoreNetwork.kill_process({"session", pid})
  end
  defp notify_terminated(_state), do: nil
end
