defmodule Moongate.Stage do
  use Moongate.Macros.Processes

  def arrive(event, stage_name) do
    tell_pid_async(event.origin.events_listener, {:arrive, stage_name})
    tell_async(:stage, stage_name, {:arrive, event.origin})
  end

  def depart(event) do
    tell_pid_async(event.origin.events_listener, {:depart, event.from})
    tell_async(event.from, {:depart, event})
  end

  def is_authenticated?(t) do
    {:ok, result} = tell_sync(:auth, {:check_auth, t.origin})
    result
  end

  def pool_name(module_name) do
    process_name = Atom.to_string(Process.info(self())[:registered_name])
    module_parts = String.split(String.downcase(Atom.to_string(module_name)), ".")
    {"stage_", pool_name} = String.split_at(process_name, 6)
    name = "pool_" <> pool_name <> List.to_string(Enum.map(tl(module_parts), &("_" <> String.downcase(&1))))
    String.to_atom(name)
  end

  def random(max) do
    :random.uniform(max)
  end

  def random_from(items) do
    elem(items, random(tuple_size(items)) - 1)
  end

  defmacro call(event, target, callback, params) do
    quote do
      pool = pool_name(unquote(target)[:__moongate_pool])
      GenServer.call(pool, {:cause, unquote(callback), unquote(target), unquote(params)})
    end
  end

  defmacro cast(event, target, callback) do
    quote do
      pool = pool_name(unquote(target)[:__moongate_pool])
      GenServer.cast(pool, {:cause, unquote(callback), unquote(target)})
    end
  end

  defmacro cast(event, target, callback, params) do
    quote do
      pool = pool_name(unquote(target)[:__moongate_pool])
      GenServer.cast(pool, {:cause, unquote(callback), unquote(target), unquote(params)})
    end
  end

  defmacro drop(event, target) do
    quote do
      pool = pool_name(unquote(target)[:__moongate_pool])
      GenServer.cast(pool, {:remove_from_pool, unquote(event), unquote(target)})
    end
  end

  defmacro find(module_name, params) do
    quote do
      pool = pool_name(unquote(module_name))
      results = GenServer.call(pool, {:get, unquote(params)})
      Enum.map(results, &(&1 ++ [__moongate_pool: unquote(module_name)]))
    end
  end

  defmacro first(module_name, params) do
    quote do
      results = find(unquote(module_name), unquote(params))
      hd(results)
    end
  end

  defmacro meta(stage_meta) do
    quote do
      def __moongate__stage_meta(_), do: __moongate__stage_meta
      def __moongate__stage_meta do
        unquote(stage_meta)
      end
    end
  end

  defmacro new(event, module_name, params) do
    quote do
      pool = pool_name(unquote(module_name))
      GenServer.cast(pool, {:add_to_pool, unquote(event), unquote(params)})
    end
  end

  defmacro pools(pool_list) do
    quote do
      def __moongate__stage_pools(_), do: __moongate__stage_pools
      def __moongate__stage_pools do
        unquote(pool_list)
      end
    end
  end

  defmacro takes(message, callback) do
    quote do
      takes unquote(message), unquote(callback), {}
    end
  end

  defmacro takes(message, callback, params) do
    quote do
      def __moongate__stage_takes({unquote(message), arguments}, event) do
        valid = tuple_size(unquote(params)) == 0 || tuple_size(unquote(params)) == tuple_size(arguments)

        if valid do
          if tuple_size(unquote(params)) == 0 do
            unquote(callback)(event, arguments)
          else
            size = tuple_size(unquote(params)) - 1
            cast_arguments = List.to_tuple(for n <- 0..size do
              case elem(unquote(params), n) do
                :int ->
                  result = Integer.parse(elem(arguments, n))
                  case result do
                    {value, leftover} -> value
                    _ -> elem(arguments, n)
                  end
                :float ->
                  result = Float.parse(elem(arguments, n))
                  case result do
                    {value, leftover} -> value
                    _ -> elem(arguments, n)
                  end
                _ -> elem(arguments, n)
              end
            end)
            unquote(callback)(event, cast_arguments)
          end
        end
      end
    end
  end
end
