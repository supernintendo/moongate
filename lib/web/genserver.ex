defmodule Moongate.Web.GenServer do
  use GenServer

  def start_link({port, path}) do
    %Moongate.Web{
      path: path,
      port: port
    }
    |> Moongate.Network.establish("socket", "#{port}", __MODULE__)
  end

  def handle_cast({:init}, state) do
    Moongate.Core.log(:up, {:socket, "Web (#{state.port})"})
    listen(state)

    {:noreply, state}
  end

  # Listen for incoming Web requests using Cowboy.
  defp listen(state) do
    Application.ensure_all_started(:cowboy)
    dispatch_config = build_dispatch_config(state)

    {:ok, _} =
      :cowboy.start_http(
        :http,
        100,
        [{:port, state.port}],
        [{:env, [{:dispatch, dispatch_config}]}]
      )
  end

  # Defines the public routes for the web server.
  defp build_dispatch_config(state) do
    world_directory = Moongate.Core.world_directory

    :cowboy_router.compile([
      {
        :_,
        [
          {"/", :cowboy_static, {:priv_file, :moongate, "#{world_directory}/#{state.path}/index.html"}},
          {"/ws", Moongate.Web.WS.Handler, []},
          {"/handshake", Moongate.Web.Handshake.Handler, state},
          {"/handshake.json", :cowboy_static, {:priv_file, :moongate, "#{world_directory}/.handshake.json"}},
          {"/moongate.js", :cowboy_static, {:priv_file, :moongate, "client/js/moongate.js"}},
          {"/[...]", :cowboy_static, {:priv_dir,  :moongate, "#{world_directory}/#{state.path}"}}
        ]
      }
    ])
  end
end