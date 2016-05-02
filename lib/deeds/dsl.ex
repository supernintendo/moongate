defmodule Moongate.Deed do
  @moduledoc """
    Provides macros and functions related to Moongate Deeds.
    Deeds are a fundamental part of the Elixir DSL.

    When Moongate launches, all modules in the server/deeds
    directory of active world's directory, are compiled.
    These modules are expected to import Moongate.Deed
    and use the following naming convention:

    <ProjectName>.Deeds.<NameOfPool>
  """
  use Moongate.Macros.Mutations

  def announce(member, message) do
  end

  def announce(member, message, params) do
  end

  def constantly(callbacks) do
  end

  def lin(member, attribute, tag, delta) do
    member
    |> mutate({:transform, :lin, attribute, tag, delta})
  end

  def get(member, key) do
    Moongate.Pool.Service.member_attr(member, key)
  end

  def set(member, key, value) do
    member
  end

  def tagged(_event, member, _message) do
    {:tagged, :drop, "pool_#{member[:__moongate_pool_name]}", "#{member[:__moongate_pool_index]}"}
  end

  defmacro transform(target, name) do
    quote do
      transform(unquote(target), unquote(name), nil)
    end
  end
  defmacro transform(target, name, params) do
    quote do
      tag = String.split(unquote(name), " ") |> List.first

      case __moongate__deed_transforms[unquote(name)] do
        {:add, attribute, :by, delta} ->
          unquote(target)
          |> lin(attribute, tag, get(unquote(target), delta))
        {:cure, attribute} ->
          unquote(target)
          |> lin(attribute, tag, 0)
        {:set, attribute} ->
          unquote(target)
          |> set(attribute, unquote(params))
        {:sub, attribute, :by, delta} ->
          unquote(target)
          |> lin(attribute, tag, get(unquote(target), delta) * -1)
        _ -> unquote(target)
      end
    end
  end

  # Data macros

  defmacro attributes(attribute_map) do
    quote do
      def __moongate__deed_attributes(_), do: __moongate__deed_attributes
      def __moongate__deed_attributes do
        Map.merge(unquote(attribute_map), %{
          origin: {:origin}
        })
      end
    end
  end

  defmacro transforms(transform_map) do
    quote do
      def __moongate__deed_transforms(_), do: __moongate__deed_transforms
      def __moongate__deed_transforms do
        unquote(transform_map)
      end
    end
  end
end
