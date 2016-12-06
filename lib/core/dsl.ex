defmodule Moongate.DSL do
  defmacro __using__(type) do
    type_module = Moongate.DSL.Helper.module_for_type(type)

    quote do
      use Moongate.State
      import unquote(type_module)

      @default_id "$"

      def get(member, key), do: Moongate.Ring.Service.member_attr(member, key)

      def join(event, zone_module), do: join(event, zone_module, @default_id)
      def join(event, zone_module, id), do: mutate(event, {:join_zone, zone_module, id})

      def push_state(%Moongate.Event{} = event, {key, value}) when is_function(value) do
        for target <- event.targets do
          push_state(target, {key, apply(value, [target])})
        end
        event
      end
      def push_state(%Moongate.Event{} = event, transaction) do
        for target <- event.targets do
          push_state(target, transaction)
        end
        event
      end
      def push_state(%Moongate.Origin{} = target, transaction) do
        %Moongate.Packet{
          body: Enum.into([transaction], %{}),
          domain: :state
        }
        |> Moongate.Network.send_packet(target)

        target
      end
      def push_state(target, _transaction), do: target
 
      def set(event, params), do: mutate(event, {:set, params})

      def subscribe(event, ring_name), do: mutate(event, {:subscribe_to_ring, ring_name})

      def target(member, value), do: mutate(member, {:target, value})

      def zone(module_name), do: zone(module_name, @default_id)
      def zone(module_name, id) do
        name = Moongate.Core.module_to_string(module_name)

        Moongate.Network.register(:zone, "#{name}_#{id}", %{
          id: id,
          name: name,
          zone: Moongate.Zone.Service.zone_module(module_name)
        })
      end    
    end
  end

  defmodule Deeds do
    defmacro attributes(attribute_map) do
      quote do
        def __deed_attributes(_), do: __deed_attributes
        def __deed_attributes do
          Map.merge(unquote(attribute_map), %{
            origin: :origin
          })
        end
      end
    end
  end

  defmodule Rings do
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
        def __ring_attributes(_), do: __ring_attributes
        def __ring_attributes do
          Map.merge(unquote(attribute_map), %{
            origin: :origin
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
  end

  defmodule Zones do
    defmacro rings(ring_list) do
      quote do
        def __zone_rings(_), do: __zone_rings
        def __zone_rings do
          unquote(ring_list)
        end
      end
    end
  end

  defmodule Helper do
    def module_for_type(type) do
      case type do
        :deed -> Moongate.DSL.Deeds
        :ring -> Moongate.DSL.Rings
        :zone -> Moongate.DSL.Zones
        _ -> Moongate.DSL.Void
      end
    end
  end

  defmodule Void do
  end
end
