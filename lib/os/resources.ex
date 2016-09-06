defmodule Moongate.OS.Resources do
  @doc """
    Compile using the current world that is set in
    our Mix config.
  """
  defmacro __before_compile__(_env) do
    if Mix.env() == :test do
      world = "test"
    else
      world = Application.get_env(:moongate, :world) || "default"
    end
    {:ok, modules} = File.ls("priv/worlds/#{world}/server")

    Enum.map(modules, fn(resource) ->
      quote do
        @external_resource "priv/worlds/#{unquote(world)}/server/#{unquote(resource)}"
      end
    end)

    quote do
      def world_name do
        unquote(world)
      end
    end
  end

  defmacro __using__(_) do
    quote do
      @before_compile Moongate.OS.Resources
    end
  end
end
