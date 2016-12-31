defmodule Moongate.Env do
  defmacro __using__(_) do
    world_name = (fn() ->
      case Mix.env do
        :test -> "test"
        _ -> Application.get_env(:moongate, :world) || "default"
      end
    end).()
    codename = (fn() ->
      case File.read("priv/metadata/codename") do
        {:ok, codename} ->
          codename
          |> String.split("\n")
          |> hd
        _ -> "Generic"
      end
    end).()
    version = (fn() ->
      case File.read("priv/metadata/version") do
        {:ok, version} ->
          version
          |> String.split("\n")
          |> hd
        _ -> "?.?.?"
      end
    end).()

    quote do
      def codename, do: unquote(codename)
      def world_name, do: unquote(world_name)
      def version, do: unquote(version)
    end
  end
end