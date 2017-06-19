defmodule Moongate.DSL.Terms.Rules do
  defmacro rules(rule_list) do
    quote do
      def __rules__(_), do: __rules__()
      def __rules__ do
        unquote(rule_list)
      end
    end
  end
end
