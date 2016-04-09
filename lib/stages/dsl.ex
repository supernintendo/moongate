defmodule Moongate.Stage do
  alias Moongate.Data, as: Data
  use Moongate.Macros.Processes

  def arrive(event, stage_name) do
    event
    |> Data.mutate({:join_stage, stage_name})
  end

  def arrive!(event, stage_name) do
    event
    |> Data.mutate({:join_stage, stage_name})
    |> Data.mutate({:set_target_stage, stage_name})
  end

  def clean(event) do
    event
    |> Data.mutate({:clean_from_all_pools})
  end

  def create(event, pool_name, attributes) do
    event
    |> Data.mutate({:create_in_pool, pool_name, attributes})
  end

  def depart(event) do
    event
    |> Data.mutate({:leave_from, event.origin})
  end

  def travel(event, stage_name) do
    event
    |> depart
    |> Data.mutate({:join_stage, stage_name})
  end

  def subscribe(event, pool_name) do
    event
    |> Data.mutate({:subscribe_to_pool, pool_name})
  end

  def is_authenticated?(t) do
    {:ok, result} = tell!({:check_auth, t.origin}, :auth)

    result
  end

  def pool_name(module_name) do
    process_name = self
    |> Process.info
    |> Keyword.get(:registered_name)
    |> Atom.to_string

    suffix = module_name
    |> Atom.to_string
    |> String.downcase
    |> String.split(".")
    |> tl
    |> Enum.map(&("__" <> String.downcase(&1)))
    |> List.to_string

    {"stage_", pool_name} = String.split_at(process_name, 6)
    "pool_#{pool_name}#{suffix}" |> String.to_atom
  end

  def random(max) do
    :random.uniform(max)
  end

  def random_from(items) do
    items
    |> elem((items |> tuple_size |> random) - 1)
  end

  def takes({_, _}, client) do
    client
  end

  defmacro call(_event, target, callback, params) do
    quote do
      pool_name(unquote(target)[:__moongate_pool])
      |> GenServer.call({:cause, unquote(callback), unquote(target), unquote(params)})
    end
  end

  defmacro cast(_event, target, callback) do
    quote do
      pool_name(unquote(target)[:__moongate_pool])
      |> GenServer.cast({:cause, unquote(callback), unquote(target)})
    end
  end

  defmacro cast(_event, target, callback, params) do
    quote do
      pool_name(unquote(target)[:__moongate_pool])
      |> GenServer.cast({:cause, unquote(callback), unquote(target), unquote(params)})
    end
  end

  defmacro find(module_name, params) do
    quote do
      pool_name(unquote(module_name))
      |> GenServer.call({:get, unquote(params)})
      |> Enum.map(&(&1 ++ [__moongate_pool: unquote(module_name)]))
    end
  end

  defmacro first(module_name, params) do
    quote do
      find(unquote(module_name), unquote(params)) |> hd
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

  defmacro pools(pool_list) do
    quote do
      def __moongate__stage_pools(_), do: __moongate__stage_pools
      def __moongate__stage_pools do
        unquote(pool_list)
      end
    end
  end
end
