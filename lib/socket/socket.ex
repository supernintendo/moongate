defmodule Moongate.Socket do
  alias Moongate.{
    CoreTypes,
    SocketState
  }
  use GenServer

  def start_link({port, params}, _name) do
    state =
      params
      |> Map.put(:port, port)
      |> CoreTypes.cast!(%SocketState{})

    GenServer.start_link(__MODULE__, state)
  end

  def handle_info(:init, %SocketState{} = state) do
    Process.flag(:trap_exit, true)
    Moongate.Core.log({:socket, "Socket {:#{state.protocol}, #{state.port}}"}, :up)

    {:noreply, listen(state)}
  end

  def handle_info(payload, %SocketState{handler_module: handler_module} = state)
  when not is_nil(handler_module) do
    handler_module.handle(payload, state)
  end

  defp listen(%SocketState{protocol: :web} = state) do
    Application.ensure_all_started(:cowboy)
    {:ok, _} =
      :cowboy.start_http(
        :http,
        100,
        [{:port, state.port}],
        [{:env, [{:dispatch, build_web_dispatch(state)}]}]
      )

    state
  end

  defp build_web_dispatch(%SocketState{} = state) do
    :cowboy_router.compile([
      {
        :_,
        [
          {"/atlas", Moongate.Socket.AtlasHandler, state},
          {"/ws", Moongate.Socket.WSHandler, state},
          {"/[...]", Moongate.Socket.StaticHandler, state}
        ]
      }
    ])
  end
end
