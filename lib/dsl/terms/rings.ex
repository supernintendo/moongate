defmodule Moongate.DSL.Terms.Rings do
  defmacro rings(ring_list) do
    quote do
      def __rings__(_), do: __rings__()
      def __rings__ do
        unquote(ring_list)
      end
    end
  end
end