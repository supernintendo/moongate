defmodule Moongate.Ring.Service do
  @moduledoc """
    Provides functions related to working with rings.
  """
  use Moongate.Core

  @doc """
    Get the member attributes as they are defined on a ring
    module.
 """
  def get_attributes(module_name) do
    apply(ring_module(module_name), :__ring_attributes, [])
  end

  @doc """
    Get the deeds as they are defined on a ring module.
  """
  def get_deeds(module_name) do
    apply(ring_module(module_name), :__ring_deeds, [])
  end

  @doc """
    Return the current value of an attribute on a ring
    member, applying all mutations.
  """
  def member_attr(member, key) do
    mutations = elem(member[key], 1)

    if length(mutations) > 0 do
      mod = Enum.reduce(mutations, 0, fn({_type, _tag, amount, time_started}, acc) ->
        acc + amount * (:erlang.system_time() - time_started)
      end)
      elem(member[key], 0) + mod
    else
      elem(member[key], 0)
    end
  end

  def member_to_string(member) do
    member
    |> Enum.map(fn({key, _value}) -> {key, member_attr(member, key)} end)
    |> Enum.map(fn({key, value}) ->
      case value do
        %Moongate.Origin{} -> {key, value.id}
        _ -> {key, value}
      end
    end)
    |> Enum.map(fn({_key, value}) -> "#{value}" end)
    |> Enum.join(",")
  end

  @doc """
    Return the actual module name for a ring when only
    given its first part.
  """
  def ring_module(module_name) do
    [world_name
     |> String.capitalize
     |> String.replace("-", "_")
     |> Mix.Utils.camelize
     |> String.to_atom, Ring, module_name]
    |> Module.safe_concat
  end

  @doc """
    Return the globally registered name for a ring process
    when given a zone name and a ring module name.
  """
  def ring_process_name(zone_process_name, module_name) do
    "#{Moongate.Utility.module_to_string(module_name)}@#{zone_process_name}"
  end

  @doc """
    Transform a list of atoms representing ring process
    names to a string containing the comma-separate
    ring names. The zone name is removed from each
    name.
  """
  def to_string_list(rings) do
    rings
    |> Enum.map(&(String.split(&1, "@")))
    |> Enum.map(&(&1 |> hd))
    |> Enum.join(" ")
  end
end
