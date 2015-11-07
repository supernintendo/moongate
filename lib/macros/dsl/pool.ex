defmodule Moongate.BatchUpdate do
  defstruct keys: [], values: []
end

defmodule Moongate.Pool do
  import Moongate.Macros.SocketWriter

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

  defmacro mutate(target, attribute, delta, params) do
    quote do
      GenServer.cast(self(), {:mutate, unquote(target), unquote(attribute), unquote(delta), unquote(params)})
    end
  end

  defmacro conveys(convey_list) do
    quote do
      def __moongate__pool_conveys(_), do: __moongate__pool_conveys
      def __moongate__pool_conveys do
        unquote(convey_list)
      end
    end
  end

  def ask(_, _) do
  end

  def attr(member, key) do
    mutations = elem(member[key], 1)

    if length(mutations) > 0 do
      mod = Enum.reduce(mutations, 0, fn(mutation, acc) ->
        acc + mutation.by * (Moongate.Time.current_ms - mutation.time_started)
      end)
      elem(member[key], 0) + mod
    else
      elem(member[key], 0)
    end
  end

  def batch(event, pool, keys) do
    attributes = Enum.map(event.pools[pool], fn(member) ->
      Enum.map(keys, fn(key) ->
        attribute = member[key]

        case attribute do
          {value, transforms} when is_number(value) ->
            represented_transforms = Enum.map(transforms, &("›#{&1.mode}:#{&1.by}")) |> Enum.join
            "#{attr(member, key)}#{represented_transforms}"
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

  def bubble(event, key) do
    stage_name = Atom.to_string(event.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:bubble, event, event.this[:__moongate__parent], key})
  end

  def tell(member, message) do
    case message do
      %Moongate.BatchUpdate{} ->
        {origin, _} = member[:origin]
        write_to(origin, :batch_update, Moongate.Packets.batch_update_for(message))
      _ -> IO.puts "foo"
    end
  end
end
