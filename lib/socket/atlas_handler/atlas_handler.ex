defmodule Moongate.Socket.AtlasHandler do
  @headers [{"Content-Type", "application/json"}]
  @packet Application.get_env(:moongate, :packet)

  def init(req, state) do
    handle(req, state)
  end

  def handle(req, state) do
    reply = :cowboy_req.reply(200, @headers, atlas(state), req)

    {:ok, reply, state}
  end

  defp atlas(state) do
    %{
      packet: @packet.atlas(),
      port: state.port
    }
    |> Map.merge(Moongate.Core.atlas)
    |> Poison.encode!()
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
