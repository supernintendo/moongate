defmodule Moongate.Core.Iex do
  defmacro __using__(_) do
    commands_module = String.to_atom("#{Application.get_env(:moongate, :dev)}Commands")

    if Code.ensure_loaded?(commands_module) do
      quote do
        import unquote(commands_module)
      end
    end
  end
end
