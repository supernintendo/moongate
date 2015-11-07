defmodule Moongate.HTTP do
  defstruct port: nil
end

defmodule Moongate.HTTP.Host do
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  def start_link(port) do
    link(%Moongate.HTTP{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (HTTP)...", :green)
    listen(state.port)

    {:noreply, state}
  end

  defp listen(port) do
    Application.ensure_all_started(:cowboy)
    dispatch = :cowboy_router.compile([{:_, routes}])
    {:ok, _} = :cowboy.start_http(:http, 100, [{:port, port}], [{ :env, [{:dispatch, dispatch}]}])
  end

  defp routes do
    [
      {"/", :cowboy_static, {:priv_file, :moongate, world_directory(:http) <> "/index.html"}},
      {"/[...]", :cowboy_static, {:priv_dir,  :moongate, world_directory(:http)}}
    ]
  end
end
