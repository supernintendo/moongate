defmodule Moongate.DSL.TermSets.Zone do
  defmacro rings(ring_list) do
    quote do
      def __zone_rings(_), do: __zone_rings()
      def __zone_rings do
        unquote(ring_list)
      end
    end
  end
end