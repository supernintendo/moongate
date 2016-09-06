defmodule Moongate.OS.Worlds do
  defmacro __using__(_) do
    if Mix.env() == :test do
      world = "test"
    else
      world = Application.get_env(:moongate, :world) || "default"
    end
    camel_world = world
    |> String.replace("-", "_")
    |> Mix.Utils.camelize

    quote do
      defp world_directory, do: world_directory(nil)
      defp world_directory(key) do
        case key do
          :http ->
            "worlds/#{unquote(world)}/http"
          _ ->
            "worlds/#{unquote(world)}"
        end
      end

      defp world_module do
        Module.safe_concat(unquote(camel_world), "World")
      end
    end
  end
end
