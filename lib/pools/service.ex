defmodule Moongate.Pool.Service do
  @moduledoc """
    Provides functions related to working with pools.
  """
  use Moongate.Macros.ExternalResources

  @doc """
    Get the member attributes as they are defined on a pool
    module.
 """
  def get_attributes(module_name) do
    apply(pool_module(module_name), :__moongate__pool_attributes, [])
  end

  @doc """
    Get the deeds as they are defined on a pool module.
  """
  def get_deeds(module_name) do
    apply(pool_module(module_name), :__moongate__pool_deeds, [])
  end

  @doc """
    Return the current value of an attribute on a pool
    member, applying all mutations.
  """
  def member_attr(member, key) do
    mutations = elem(member[key], 1)

    if length(mutations) > 0 do
      mod = Enum.reduce(mutations, 0, fn({type, tag, amount, time_started}, acc) ->
        acc + amount * (Moongate.Time.current_ms - time_started)
      end)
      elem(member[key], 0) + mod
    else
      elem(member[key], 0)
    end
  end

  def member_to_string(member) do
    member
    |> Enum.map(fn({key, value}) -> {key, member_attr(member, key)} end)
    |> Enum.map(fn({key, value}) ->
      case value do
        %Moongate.Origin{} -> {key, value.auth.identity}
        _ -> {key, value}
      end
    end)
    |> Enum.map(fn({key, value}) -> "#{key}:¦#{value}¦" end)
    |> Enum.join(" ")
  end

  @doc """
    Return the actual module name for a pool when only
    given its first part.
  """
  def pool_module(module_name) do
    [world_name
     |> String.capitalize
     |> String.replace("-", "_")
     |> Mix.Utils.camelize
     |> String.to_atom, Pool, module_name]
    |> Module.safe_concat
  end

  @doc """
    Return the globally registered name for a pool process
    when given a stage name and a pool module name.
  """
  def pool_process_name(stage_process_name, module_name) do
    "#{Moongate.Modules.to_string(module_name)}__for__#{stage_process_name}"
  end

  @doc """
    Transform a list of atoms representing pool process
    names to a string containing the comma-separate
    pool names. The stage name is removed from each
    name.
  """
  def to_string_list(pools) do
    pools
    |> Enum.map(&(String.split(&1, "__for__")))
    |> Enum.map(&(&1 |> hd))
    |> Enum.join(" ")
  end
end
