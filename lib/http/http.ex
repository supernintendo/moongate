defmodule Moongate.HTTP do
  defstruct dispatch: nil, port: nil
end

defmodule Moongate.HTTP.Host do
  use Cauldron
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  def start_link(port) do
    link(%Moongate.HTTP{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (HTTP)...", :green)
    Cauldron.start &handle/3, port: state.port

    {:noreply, state}
  end

  def handle("GET", %URI{path: path}, req) do
    if path == "/" do
      path = "/index.html"
    end

    cond do
      File.exists?(world_directory(:http) <> path) ->
        req |> Request.reply(200, File.open!(world_directory(:http) <> path))
      File.exists?(world_directory(:http) <> path <> ".html") ->
        req |> Request.reply(200, File.open!(world_directory(:http) <> path <> ".html"))
      true ->
        req |> Request.reply(404)
    end
  end
end
