defmodule Moongate.DSL.Terms.Data do
  defmacro data(path) do
    quote do
      Moongate.CoreGameData.game_data(unquote(path))
    end
  end
end
