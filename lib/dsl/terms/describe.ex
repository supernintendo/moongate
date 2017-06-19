defmodule Moongate.DSL.Terms.Describe do
  defmacro describe(contents) do
    contents =
      case contents do
        [do: block] ->
          quote do
            unquote(block)
          end
        _ ->
          quote do
            try(unquote(contents))
          end
      end

    contents = Macro.escape(contents, unquote: true)

    quote bind_quoted: [contents: contents] do
      name = String.to_atom("__description__")

      def unquote(name)(), do: unquote(contents)
    end
  end
end