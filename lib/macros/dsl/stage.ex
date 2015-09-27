defmodule Moongate.Stage do
  use Moongate.Macros.Processes

  def is_authenticated?(t) do
    {:ok, result} = tell(:auth, {:check_auth, t.origin})
    result
  end

  def kick(event) do
    tell_async(event.from, {:kick, event.origin})
  end

  def join(event, stage_name) do
    tell_async(:stage, stage_name, {:join, event.origin})
  end

  defmacro new(module_name, params) do
    quote do
      process_name = Process.info(self())[:registered_name]
      module_parts = String.split(String.downcase(Atom.to_string(unquote(module_name))), ".")
      name = "pools_" <> Atom.to_string(process_name) <> List.to_string(Enum.map(tl(module_parts), &("_" <> String.downcase(&1))))
      GenServer.cast(String.to_atom(name), {:add_to_pool, unquote(params)})
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

  defmacro meta(stage_meta) do
    quote do
      def __moongate__stage_meta(_), do: __moongate__stage_meta
      def __moongate__stage_meta do
        unquote(stage_meta)
      end
    end
  end

  defmacro takes(message, callback) do
    quote do
      takes unquote(message), unquote(callback), unquote({})
    end
  end

  defmacro takes(message, callback, params) do
    quote do
      def __moongate__stage_takes({unquote(message), params}, event) do
        unquote(callback)(event, params)
      end
    end
  end
end
