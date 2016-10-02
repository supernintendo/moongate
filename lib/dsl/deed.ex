defmodule Moongate.Deeds do
  @moduledoc """
    Provides the DSL for deeds (a deed is a
    set of functions on a ring)
  """
  use Moongate.Mutations

  @doc """
    Mark the ring member with a linear transformation
    over an attribute with a given delta and tag.
  """
  def lin(member, attribute, tag, delta) do
    member
    |> mutate({:transform, :lin, attribute, tag, delta})
  end

  @doc """
    Return the current value of an attribute on
    a member, including transformations.
  """
  def get(member, key) do
    Moongate.Ring.Service.member_attr(member, key)
  end

  @doc """
    Set an attribute of a member to a value.
  """
  def set(member, key, value) do
    member
    |> mutate({:set, key, value})
  end

  @doc """
    Send a message to all subscribers of this ring
    containing the index of a ring member.
  """
  def tagged(_event, member, _message) do
    {:tagged,
      :drop,
      "ring_#{member[:__moongate_ring_name]}",
      "#{member[:__moongate_ring_index]}"}
  end

  @doc """
    Find a transformation in the `transforms` map and
    apply it to a ring member with no parameters.
  """
  defmacro transform(target, name) do
    quote do
      transform(unquote(target), unquote(name), nil)
    end
  end

  @doc """
    Find a transformation in the `transforms` map and
    apply it to a ring member.
  """
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

  @doc """
    Defines the attributes that a ring needs in order
    for the deed to be used on it.
  """
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

  @doc """
    Defines the list of ring members transformations
    on this deed. These can be references using
    &transform/2 and &transform/3.
  """
  defmacro transforms(transform_map) do
    quote do
      def __moongate__deed_transforms(_), do: __moongate__deed_transforms
      def __moongate__deed_transforms do
        unquote(transform_map)
      end
    end
  end
end
