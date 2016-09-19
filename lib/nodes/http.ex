defmodule Moongate.HTTP.Node do
  @moduledoc """
    Provides an HTTP server for serving static assets.
  """
  use GenServer
  use Moongate.OS

  @doc """
    Start the HTTP server.
  """
  def start_link({port, path}) do
    %Moongate.HTTP{
      path: path,
      port: port
    }
    |> establish("socket", "#{port}")
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    log(:up, {:socket, "HTTP (#{state.port})"})
    listen(state)

    {:noreply, state}
  end

  # Listen for incoming HTTP requests using Cowboy.
  defp listen(state) do
    Application.ensure_all_started(:cowboy)
    dispatch = :cowboy_router.compile([{:_, routes(state.path)}])
    {:ok, _} = :cowboy.start_http(:http, 100, [port: state.port], [
      env: [dispatch: dispatch],
      middlewares: [:cowboy_router, Moongate.HTTP.Service, :cowboy_handler]
    ])
  end

  # Defines the public routes for the web server.
  defp routes(path) do
    [
      {"/", :cowboy_static, {:priv_file, :moongate, "#{world_directory}/#{path}/index.html"}},
      {"/handshake.json", :cowboy_static, {:priv_file, :moongate, "#{world_directory}/.handshake.json"}},
      {"/moongate.js", :cowboy_static, {:priv_file, :moongate, "client/bin/moongate.js"}},
      {"/moongate.js.mem", :cowboy_static, {:priv_file, :moongate, "client/bin/moongate.js.mem"}},
      {"/[...]", :cowboy_static, {:priv_dir,  :moongate, "#{world_directory}/#{path}"}}
    ]
  end
end
