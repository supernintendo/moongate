defmodule Moongate.DSL.Terms.Handle do
  defmacro handle(event_name, var \\ quote(do: _), contents) do
    base_name = handler_base_name(event_name)
    quote bind_quoted: [
      base_name: String.to_atom(base_name),
      body: Macro.escape(handler_body(contents), unquote: true),
      handler_function_name: String.to_atom("handle_#{base_name}_event"),
      var: Macro.escape(var)
    ] do
      def unquote(handler_function_name)(unquote(var)), do: unquote(body)
    end
  end

  defp handler_base_name(event_name) do
    case event_name do
      event_name when is_tuple(event_name) ->
        elem(event_name, 0)
      event_name when is_atom(event_name) or is_bitstring(event_name) ->
        "#{event_name}"
      _ ->
        throw "Bad event name for handler: #{IO.inspect event_name}"
    end
  end

  defp handler_body(contents) do
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
  end
end
