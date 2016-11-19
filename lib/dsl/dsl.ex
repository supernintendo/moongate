defmodule Moongate.Rings do
  @moduledoc """
    Provides macros which describe the foundational data
    structures and functions of a Moongate ring. A Ring
    may be thought of as a collection of similar entities
    within a game. Rings are a fundamental part of the
    Elixir DSL.

    When Moongate launches, all modules in the server/rings
    directory of active world's directory are compiled.
    These modules are expected to import Moongate.Ring
    and use the following naming convention:

    <ProjectName>.Ring.<NameOfRing>
  """

  # Data macros

  defmacro attributes(attribute_map) do
    quote do
      def __ring_attributes(_), do: __ring_attributes
      def __ring_attributes do
        Map.merge(unquote(attribute_map), %{
          origin: {:origin}
        })
      end
    end
  end

  defmacro deeds(deed_list) do
    quote do
      def __ring_deeds(_), do: __ring_deeds
      def __ring_deeds do
        unquote(deed_list)
      end
    end
  end

  defmacro events(event_list) do
    quote do
      def __ring_events(_), do: __ring_events
      def __ring_events do
        unquote(event_list)
      end
    end
  end

  defmacro public(publish_list) do
    quote do
      def __ring_publishes(_), do: __ring_publishes
      def __ring_publishes do
        unquote(publish_list)
      end
    end
  end

  defmacro listens(listener_list) do
    quote do
      def __ring_listens(_), do: __ring_listens
      def __ring_listens do
        unquote(listener_list)
      end
    end
  end

  defmacro upon(upon_map) do
    quote do
      def __ring_upons(_), do: __ring_upons
      def __ring_upons do
        unquote(upon_map)
      end
    end
  end
end
