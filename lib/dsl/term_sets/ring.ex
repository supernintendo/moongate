defmodule Moongate.DSL.TermSets.Ring do
  defmacro create(event) do
    quote do
      mutate(unquote(event), {:add_member, %{}})
    end
  end

  defmacro create(event, attributes) do
    quote do
      mutate(unquote(event), {:add_member, unquote(attributes)})
    end
  end

  defmacro drop(event, _attributes) do
    quote do
      IO.puts "TODO: Drop"
      unquote(event)
    end
  end

  defmacro find_by(event, _key, _value) do
    quote do
      IO.puts "TODO: Find By"
      unquote(event)
    end
  end

  defmacro attributes(attribute_map) do
    quote do
      def __ring_attributes(_), do: __ring_attributes()
      def __ring_attributes do
        Map.merge(unquote(attribute_map), %{
          origin: :origin
        })
      end
    end
  end

  defmacro deeds(deed_list) do
    quote do
      def __ring_deeds(_), do: __ring_deeds()
      def __ring_deeds do
        unquote(deed_list)
      end
    end
  end

  defmacro events(event_list) do
    quote do
      def __ring_events(_), do: __ring_events()
      def __ring_events do
        unquote(event_list)
      end
    end
  end

  defmacro public(publish_list) do
    quote do
      def __ring_publishes(_), do: __ring_publishes()
      def __ring_publishes do
        unquote(publish_list)
      end
    end
  end
end