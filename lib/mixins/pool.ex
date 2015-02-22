defmodule Mixins.Pool do
  defmacro __using__(_) do
    quote do
      defp for_pool(collection, schema) do
        Enum.reduce(collection, "", &to_pool_item(&1, &2, schema))
      end

      defp to_pool_item(item, acc, schema) do
        if is_tuple(item) do
          item = elem(item, 1)
        end

        pool_item = elem(Enum.reduce(schema, {"", 0}, &pool_item_arg(&1, &2, item)), 0)

        acc <> "#{pool_item}|"
      end

      defp pool_item_arg(arg, acc, item) do
        value = Map.get(item, arg)
        {elem(acc, 0) <> "#{value};", elem(acc, 1)}
      end
    end
  end
end