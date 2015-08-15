defmodule Macros.Worlds do
  defmacro __using__(_) do
    {:ok, read} = File.read "config/config.json"
    {:ok, config} = JSON.decode(read)
    world = config["world"] || "default"

    if File.dir?("worlds/#{world}/http") do
      quote do
        def world_http_directory do
          world = unquote(world)
          "worlds/#{world}/http"
        end
      end
    end
  end
end