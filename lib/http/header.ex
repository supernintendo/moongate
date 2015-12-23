defmodule Moongate.HTTP.Headers do
  @behavior :cowboy_middleware

  def execute(req, env) do
    route = elem(:cowboy_req.path(req), 0)
    parts = String.split(route, ".")

    case List.last(parts) do
      "js" ->
        source_map = String.lstrip(route, ?/) <> ".map"
        modified = :cowboy_req.set_resp_header("X-SourceMap", source_map, req)
      _ ->
        modified = req
    end

    {:ok, modified, env}
  end
end
