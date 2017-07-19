defmodule Moongate.DSL.Terms.Fibers do
  defmacro fiber(fiber_list, args) do
    quote do
      def __fiber__(_), do: __fibers__()
      def __fiber__ do
        unquote(fiber_list)
      end
    end
  end
end
