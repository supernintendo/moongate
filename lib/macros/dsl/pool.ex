defmodule Moongate.SyncEvent do
  defstruct keys: [], pool: nil, values: []
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

  defmacro set(target, attribute, value) do
    quote do
      GenServer.cast(self(), {:set, unquote(target), unquote(attribute), unquote(value)})
    end
  end

  defmacro cascades(cascade_list) do
    quote do
      def __moongate__pool_cascades(_), do: __moongate__pool_cascades
      def __moongate__pool_cascades do
        unquote(cascade_list)
      end
    end
  end

  defmacro touches(touch_list) do
    quote do
      def __moongate__pool_touches(_), do: __moongate__pool_touches
      def __moongate__pool_touches do
        unquote(touch_list)
      end
    end
  end

  def attr(member, key) do
    Moongate.Data.pool_member_attr(member, key)
  end

  def tagged(event, member, message) do
    {:tagged, :drop, "pool_#{member[:__moongate_pool_name]}", "#{member[:__moongate_pool_index]}"}
  end

  def sync(event, pool, keys), do: sync(event.pools[pool], keys)
  def sync(pool, keys) do
    keys = [:__moongate_pool_index] ++ keys
    attributes = Enum.map(pool, fn(member) ->
      Enum.map(keys, fn(key) ->
        attribute = member[key]

        case attribute do
          {value, transforms} when is_number(value) ->
            represented_transforms = Enum.map(transforms, &("›#{&1.mode}:#{&1.by}")) |> Enum.join
            "#{attr(member, key)}#{represented_transforms}"
          {%Moongate.SocketOrigin{}, transforms} ->
            origin = elem(attribute, 0)
            origin.auth.identity
          {value, transforms} -> value
          value -> value
        end
      end)
    end)
    %Moongate.SyncEvent{
      keys: keys,
      pool: Process.info(self())[:registered_name],
      values: attributes
    }
  end

  def bubble(event, key) do
    stage_name = Atom.to_string(event.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:bubble, event, event.this[:__moongate_pool], key})
  end

  def bubble(event, key, params) do
    stage_name = Atom.to_string(event.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:bubble, %{event | params: params}, event.this[:__moongate_pool], key})
  end

  def echo(event, params) do
    stage_name = Atom.to_string(event.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:echo, event, event.this[:__moongate_pool], params})
  end

  def echo_after(delay, event, params) do
    :timer.apply_after(delay, __MODULE__, :echo, [event, params])
  end

  def tell(member, message) do
    {origin, _} = member[:origin]

    case message do
      %Moongate.SyncEvent{} ->
        if message.pool do
          write_to(origin, :sync, Atom.to_string(message.pool), Moongate.Packets.sync(message))
        else
          write_to(origin, :sync, Moongate.Packets.sync(message))
        end
      {:tagged, tag, pool, index} -> write_to(origin, tag, pool, index)
      _ -> nil
    end
  end
end
