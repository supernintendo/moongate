defmodule Moongate.Macros.Worlds do
  defmacro __using__(_) do
    {:ok, read} = File.read "config/config.json"
    {:ok, config} = JSON.decode(read)
    world = config["world"] || "default"

    quote do
      defp world_directory(key) do
        world = unquote(world)

        case key do
          :http ->
            "worlds/#{world}/http"
          _ ->
            "worlds/#{world}"
        end
      end
    end
  end
end