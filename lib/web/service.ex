defmodule Moongate.Web.Service do
  @behaviour :cowboy_middleware

  def execute(req, env) do
    route = elem(:cowboy_req.path(req), 0)
    parts = String.split(route, ".")

    case List.last(parts) do
      "json" ->
        modified = :cowboy_req.set_resp_header("Content-Type", "application/json", req)
        {:ok, modified, env}
      "js" ->
        source_map = String.lstrip(route, ?/) <> ".map"
        modified = :cowboy_req.set_resp_header("X-SourceMap", source_map, req)
        {:ok, modified, env}
      _ ->
        {:ok, req, env}
    end
  end
end
