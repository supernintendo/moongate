defmodule HTTP do
  defstruct dispatch: nil, port: nil
end

defmodule HTTP.Host do
  use Cauldron
  use Macros.Translator
  use Macros.Worlds

  def start_link(port) do
    link(%HTTP{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Say.pretty("Listening on port #{state.port} (HTTP)...", :green)
    Cauldron.start &handle/3, port: state.port

    {:noreply, state}
  end

  def handle("GET", %URI{path: path}, req) do
    if path == "/" do
      path = "/index.html"
    end

    if File.exists?(world_http_directory <> path) do
      req |> Request.reply(200, File.open!(world_http_directory <> path))
    else
      req |> Request.reply(404)
    end
  end
end
