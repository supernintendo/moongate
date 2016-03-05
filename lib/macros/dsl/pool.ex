defmodule Moongate.Pool do
  @moduledoc """
    Provides macros which describe the foundational data
    structures and functions of a Moongate Pool. A Pool
    may be thought of as a collection of similar entities
    within a game. Pools are a fundamental part of the
    Elixir DSL.

    When Moongate launches, all modules in the server/pools
    directory of active world's directory are compiled.
    These modules are expected to import Moongate.Pool
    and use the following naming convention:

    <ProjectName>.Pools.<NameOfPool>
  """

  # Data macros

  defmacro attributes(attribute_map) do
    quote do
      def __moongate__pool_attributes(_), do: __moongate__pool_attributes
      def __moongate__pool_attributes do
        attributes = Map.merge(unquote(attribute_map), %{
          origin: {:origin}
        })
        attributes
      end
    end
  end

  defmacro deeds(deed_list) do
    quote do
      def __moongate__pool_deeds(_), do: __moongate__pool_deeds
      def __moongate__pool_deeds do
        unquote(deed_list)
      end
    end
  end

  defmacro events(event_list) do
    quote do
      def __moongate__pool_events(_), do: __moongate__pool_events
      def __moongate__pool_events do
        unquote(event_list)
      end
    end
  end

  defmacro private(private_list) do
    quote do
      def __moongate__pool_privates(_), do: __moongate__pool_privates
      def __moongate__pool_privates do
        unquote(private_list)
      end
    end
  end

  defmacro publishes(publish_list) do
    quote do
      def __moongate__pool_publishes(_), do: __moongate__pool_publishes
      def __moongate__pool_publishes do
        unquote(publish_list)
      end
    end
  end

  defmacro subscribes(subscribe_list) do
    quote do
      def __moongate__pool_subscribes(_), do: __moongate__pool_subscribes
      def __moongate__pool_subscribes do
        unquote(subscribe_list)
      end
    end
  end

  defmacro upon(upon_map) do
    quote do
      def __moongate__pool_upons(_), do: __moongate__pool_upons
      def __moongate__pool_upons do
        unquote(upon_map)
      end
    end
  end
end
