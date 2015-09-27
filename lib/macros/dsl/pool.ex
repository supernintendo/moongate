defmodule Moongate.BatchUpdate do
  defstruct keys: [], values: []
end

defmodule Moongate.Pool do
  defmacro attributes(attribute_map) do
    quote do
      def __moongate__pool_attributes(_), do: __moongate__pool_attributes
        def __moongate__pool_attributes do
          attributes = Map.merge(unquote(attribute_map), %{
            origin: {:origin}
          })
          attributes
      end
    end
  end

  defmacro triggers(trigger_list) do
    quote do
      def __moongate__pool_triggers(_), do: __moongate__pool_triggers
      def __moongate__pool_triggers do
        unquote(trigger_list)
      end
    end
  end

  def ask(_, _) do
  end

  def batch(event, pool, keys) do
    attributes = Enum.map(event.pools[pool], fn(member) ->
      Enum.map(keys, fn(key) ->
        attribute = member[key]

        case attribute do
          {value, transforms} -> value
          %Moongate.SocketOrigin{} -> attribute.id
        end
      end)
    end)
    %Moongate.BatchUpdate{
      keys: keys,
      values: attributes
    }
  end

  def set(_, _, _) do
  end

  def tell(member, message) do
  end

  def trigger(_, _) do
  end
end
