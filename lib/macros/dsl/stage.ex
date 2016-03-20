defmodule Moongate.Stage do
  alias Moongate.Service.Stages, as: Stages
  use Moongate.Macros.Processes

  def arrive(event, stage_name), do: Stages.arrive(event, stage_name)
  def arrive!(event, stage_name), do: Stages.arrive!(event, stage_name)
  def depart(event), do: Stages.depart(event)

  def travel(event, stage_name) do
    depart(event)
    arrive!(event, stage_name)
  end

  def subscribe(origin, pool) do
    tell!({:subscribe, origin}, pool_name(pool))
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
    "pool_#{pool_name}#{suffix}" |> String.to_atom |> IO.inspect
  end

  def random(max) do
    :random.uniform(max)
  end

  def random_from(items) do
    items |> elem((items |> tuple_size |> random) - 1)
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

  defmacro drop(event, target) do
    quote do
      pool_name(unquote(target)[:__moongate_pool])
      |> GenServer.cast({:remove_from_pool, unquote(event), unquote(target)})
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

  defmacro new(event, module_name, params) do
    quote do
      pool_name(unquote(module_name))
      |> GenServer.cast({:add_to_pool, unquote(event), unquote(params)})
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
