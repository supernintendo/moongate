defmodule Moongate.Macros.ExternalResources do
  defmacro __before_compile__(_env) do
    {:ok, read} = File.read "config/config.json"
    {:ok, config} = JSON.decode(read)
    world = config["world"] || "default"

    {:ok, modules} = File.ls("worlds/#{world}/modules")
    {:ok, scopes} = File.ls("worlds/#{world}/scopes")

    Enum.map(modules, fn(resource) ->
      quote do
        @external_resource "worlds/#{unquote(world)}/modules/#{unquote(resource)}"
      end
    end)

    Enum.map(scopes, fn(resource) ->
      quote do
        @external_resource "worlds/#{unquote(world)}/scopes/#{unquote(resource)}"
      end
    end)
  end

  defmacro __using__(_) do
    quote do
      @before_compile Moongate.Macros.ExternalResources
    end
  end
end