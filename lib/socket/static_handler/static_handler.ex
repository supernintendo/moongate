defmodule Moongate.Socket.StaticHandler do
  alias Moongate.CoreFirmware

  @default_prefix ~r/^(Moongate)\//
  @error_headers [{"Content-Type", "text/html"}]
  @error_pages %{
    "404" => File.read!("priv/web/404.html"),
    "500" => File.read!("priv/web/500.html")
  }
  @game_path CoreFirmware.game_path()
  @headers []
  @mime_types Poison.decode!(File.read!("priv/web/mime_types.json"))

  def init(req, state) do
    handle(req, state)
  end

  def handle(req, state) do
    case content(req, state) do
      {status, headers, response} ->
        {:ok, :cowboy_req.reply(status, headers, response, req), state}
      _ ->
        {:ok, :cowboy_req.reply(500, @error_headers, @error_pages["500"] || "500 Internal Server Error", req), state}
    end
  end

  defp content(req, state) do
    :cowboy_req.path_info(req)
    |> format_path
    |> response_result
    |> prepare_content(state)
  end

  defp content_type_header(path) do
    [{"Content-Type", mime_type(Path.extname(path))}]
  end

  defp filename_for_path(path, state) do
    cond do
      Regex.match?(@default_prefix, path) ->
        "priv/web/#{Regex.replace(@default_prefix, path, "")}"
      true ->
        "#{@game_path}/#{state.public}/#{path}"
    end
  end

  defp format_path([]), do: ""
  defp format_path(path_info) do
    path_info
    |> Path.join
  end

  defp get_static_file_contents(filename) do
    case File.read(filename) do
      {:ok, contents} when is_bitstring(contents) -> {:ok, contents}
      _ -> {:error, :enoent}
    end
  end

  defp mime_type(extension) do
    @mime_types[extension] || "application/octet-stream"
  end

  defp prepare_content({:file, path}, state) do
    case get_static_file_contents(filename_for_path(path, state)) do
      {:ok, contents} ->
        {200, @headers ++ content_type_header(path), contents}
      {:error, :enoent} ->
        {404, @headers ++ @error_headers, @error_pages["404"] || "404 Not Found"}
      _ ->
        {500, @headers ++ @error_headers, @error_pages["500"] || "500 Internal Server Error"}
    end
  end

  defp response_result(path_info) do
    case path_info do
      "" -> {:file, "index.html"}
      path when is_bitstring(path) -> {:file, path}
      _ -> :error
    end
  end
end
