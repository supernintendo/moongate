defmodule Moongate.Stage do
  use Moongate.Macros.Processes

  def enroll(transaction, stage_name) do
    tell_async(:stage, stage_name, {:enroll, transaction.origin})
  end

  def kick(transaction) do
    tell_async(transaction.from, {:kick, transaction.origin})
  end

  defmacro pools(pool_map) do
    quote do
      def __moongate__stage_pools(_), do: __moongate__stage_pools
      def __moongate__stage_pools do
        unquote(pool_map)
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
      def __moongate__stage_takes({unquote(message), params}, transaction) do
        unquote(callback)(transaction, params)
      end
    end
  end
end