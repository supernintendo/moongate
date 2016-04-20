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

  def announce(member, message) do
  end

  def announce(member, message, params) do
  end

  def get(member, key) do
    Moongate.Data.pool_member_attr(member, key)
  end

  def tagged(_event, member, _message) do
    {:tagged, :drop, "pool_#{member[:__moongate_pool_name]}", "#{member[:__moongate_pool_index]}"}
  end

  defmacro lin(target, attribute, delta) do
  end

  defmacro transform(target, attribute, delta) do
    quote do
      GenServer.cast(self(), {:transform, unquote(target), unquote(attribute), unquote(delta)})
    end
  end

  defmacro set(target, attribute, value) do
    quote do
      GenServer.cast(self(), {:set, unquote(target), unquote(attribute), unquote(value)})
    end
  end

  # Data macros

  defmacro attributes(attribute_map) do
    quote do
      def __moongate__pool_attributes(_), do: __moongate__pool_attributes
      def __moongate__pool_attributes do
        Map.merge(unquote(attribute_map), %{
          origin: {:origin}
        })
      end
    end
  end
end
