defmodule Moongate.Web.Handshake.Handler do
  @encoder Application.get_env(:moongate, :packets).encoder
  @headers [{"Content-Type", "application/json"}]

  def init(req, state) do
    handle(req, state)
  end

  def handle(req, state) do
    reply = :cowboy_req.reply(200, @headers, handshake(state), req)

    {:ok, reply, state}
  end

  defp handshake(state) do
    %{
      operations: Enum.into(@encoder.operations, %{}),
      port: state.port
    }
    |> Map.merge(Moongate.Core.handshake)
    |> Poison.encode!
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
