defmodule Moongate.Env do
  defmacro __using__(_) do
    world_name = (fn() ->
      case Mix.env do
        :test -> "test"
        _ -> Application.get_env(:moongate, :world) || "default"
      end
    end).()

    quote do
      def world_name do
        unquote(world_name)
      end
    end
  end
end