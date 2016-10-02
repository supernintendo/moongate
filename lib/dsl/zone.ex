defmodule Moongate.Zones do
  @moduledoc """
    Provides the DSL for zones (a zone is a
    collection of rings)
  """
  use Moongate.OS
  use Moongate.Mutations

  def arrive(event, zone_module), do: arrive(event, zone_module, "$")
  def arrive(event, zone_module, id) do
    event
    |> mutate({:join_zone, zone_module, id})
    |> mutate({:set_target_zone, zone_module, id})
  end

  def clean(event) do
    event
    |> mutate({:clean_from_all_rings})
  end

  def create(event, ring_name, attributes) do
    event
    |> mutate({:create_in_ring, ring_name, attributes})
  end

  def depart(event) do
    event
    |> mutate({:leave_from, event.origin})
  end

  def get(member, key) do
    Moongate.Ring.Service.member_attr(member, key)
  end

  def travel(event, zone_module, id) do
    event
    |> depart
    |> arrive(zone_module, id)
  end

  def travel(event, zone_module) do
    event
    |> depart
    |> arrive(zone_module)
  end

  def subscribe(event, ring_name) do
    event
    |> mutate({:subscribe_to_ring, ring_name})
  end

  def ring_name(module_name) do
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

    {"zone_", ring_name} = String.split_at(process_name, 6)
    "ring_#{ring_name}#{suffix}" |> String.to_atom
  end

  def random(max) do
    :rand.uniform(max)
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
      ring_name(unquote(module_name))
      |> GenServer.call({:get, unquote(params)})
      |> Enum.map(&(&1 ++ [__moongate_ring: unquote(module_name)]))
    end
  end

  defmacro first(module_name, params) do
    quote do
      find(unquote(module_name), unquote(params)) |> hd
    end
  end

  defmacro meta(zone_meta) do
    quote do
      def __moongate__zone_meta(_), do: __moongate__zone_meta
      def __moongate__zone_meta do
        unquote(zone_meta)
      end
    end
  end

  defmacro rings(ring_list) do
    quote do
      def __moongate__zone_rings(_), do: __moongate__zone_rings
      def __moongate__zone_rings do
        unquote(ring_list)
      end
    end
  end
end
