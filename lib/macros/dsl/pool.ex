defmodule Moongate.Pool do
  defmacro aspects(aspect_map) do
    quote do
      def __moongate__pool_aspects(_), do: __moongate__pool_aspects
      def __moongate__pool_aspects do
        unquote(aspect_map)
      end
    end
  end
end