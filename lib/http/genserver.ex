defmodule Moongate.HTTP.GenServer do
  @moduledoc """
    Provides an HTTP server for serving static assets.
    Moongate.js is automatically accessible from all
    HTTP servers.
  """
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  @doc """
    Start the HTTP server.
  """
  def start_link({port, path}) do
    link(%Moongate.HTTP.GenServer.State{path: path, port: port}, "socket", "#{port}")
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (HTTP)...", :green)
    listen(state)

    {:noreply, state}
  end

  # Listen for incoming HTTP requests using Cowboy.
  defp listen(state) do
    Application.ensure_all_started(:cowboy)
    dispatch = :cowboy_router.compile([{:_, routes(state.path)}])
    {:ok, _} = :cowboy.start_http(:http, 100, [port: state.port], [
      env: [dispatch: dispatch],
      middlewares: [:cowboy_router, Moongate.HTTP.Middleware.Headers, :cowboy_handler]
    ])
  end

  # Defines the public routes for the web server.
  defp routes(path) do
    [
      {"/", :cowboy_static, {:priv_file, :moongate, "#{world_directory}/#{path}/index.html"}},
      {"/moongate.js", :cowboy_static, {:priv_file, :moongate, "clients/js/public/app.js"}},
      {"/moongate.js.map", :cowboy_static, {:priv_file, :moongate, "clients/js/public/app.js.map"}},
      {"/moongate-manifest.json", :cowboy_static, {:priv_file, :moongate, "temp/manifest.json"}},
      {"/[...]", :cowboy_static, {:priv_dir,  :moongate, "#{world_directory}/#{path}"}}
    ]
  end
end
