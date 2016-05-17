defmodule Moongate.Stage do
  @moduledoc """
    Provides the DSL for stages (a stage is a
    collection of pools)
  """
  use Moongate.Macros.Mutations
  use Moongate.Macros.Processes

  def arrive(event, stage_module), do: arrive(event, stage_module, "🔮")
  def arrive(event, stage_module, id) do
    event
    |> mutate({:join_stage, stage_module, id})
    |> mutate({:set_target_stage, stage_module, id})
  end

  def clean(event) do
    event
    |> mutate({:clean_from_all_pools})
  end

  def create(event, pool_name, attributes) do
    event
    |> mutate({:create_in_pool, pool_name, attributes})
  end

  def depart(event) do
    event
    |> mutate({:leave_from, event.origin})
  end

  def get(member, key) do
    Moongate.Pool.Service.member_attr(member, key)
  end

  def travel(event, stage_module, id) do
    event
    |> depart
    |> arrive(stage_module, id)
  end

  def travel(event, stage_module) do
    event
    |> depart
    |> arrive(stage_module)
  end

  def subscribe(event, pool_name) do
    event
    |> mutate({:subscribe_to_pool, pool_name})
  end

  def is_authenticated?(t) do
    {:ok, result} = ask({:check_auth, t.origin}, "tree_auth")

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
