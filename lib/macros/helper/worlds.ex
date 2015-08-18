defmodule Moongate.Macros.Worlds do
  defmacro __using__(_) do
    {:ok, read} = File.read "config/config.json"
    {:ok, config} = JSON.decode(read)
    world = config["world"] || "default"
    camel_world = Mix.Utils.camelize(world)

    quote do
      defp world_module do
        Module.safe_concat(unquote(camel_world), "Game")
      end

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