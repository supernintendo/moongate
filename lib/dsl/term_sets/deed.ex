defmodule Moongate.DSL.TermSets.Deed do
  defmacro attributes(attribute_map) do
    quote do
      def __deed_attributes(_), do: __deed_attributes
      def __deed_attributes do
        Map.merge(unquote(attribute_map), %{
          origin: :origin
        })
      end
    end
  end
end