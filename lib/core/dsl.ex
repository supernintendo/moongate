defmodule Moongate.DSL do
  defmacro __using__(type) do
    type_module = (fn ->
      case type do
        :deed -> Moongate.DSL.Deeds
        :ring -> Moongate.DSL.Rings
        :zone -> Moongate.DSL.Zones
        _ -> Moongate.DSL.Void
      end
    end).()

    quote do
      use Moongate.State
      import unquote(type_module)

      @default_id "$"

      @doc """
      Gets the current value of a pool member attribute
      by key.
      """
      def get(member, key), do: Moongate.Ring.Service.member_attr(member, key)

      @doc """
      Mutates an event to cause its targets to join the
      specified zone when the event is processed. If no
      zone ID is passed, the default zone ID ($) is used
      instead.
      """
      def join(event, zone_module), do: join(event, zone_module, @default_id)
      def join(event, zone_module, id), do: mutate(event, {:join_zone, zone_module, id})

      @doc """
      Sends a state packet to all targets attached to an
      event. For the default client reference
      implementation, this effectively sets a key
      value pair within the `state` object of the active
      Moongate instance. If `value` is a function, that
      function is called once for every target, with the
      target being passed to the function call as a single
      argument.
      """
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

      @doc """
      Mutates an event to modify attributes on all attached
      targets when the event is processed. `&set/2` takes a
      map as the second argument, in which case all key value
      pairs within the map override the targets' attributes.
      `&set/3` takes a key and a value, making it more
      suitable for cases in which only a single attribute
      is being set.
      """
      def set(event, params) when is_map(params), do: mutate(event, {:set, params})
      def set(event, key, value) when is_atom(key) do
        params = Map.put(%{}, key, value)
        mutate(event, {:set, params})
      end

      def subscribe(event, ring_name), do: mutate(event, {:subscribe_to_ring, ring_name})

      def target(member, value), do: mutate(member, {:target, value})

      def zone(module_name), do: zone(module_name, @default_id)
      def zone(module_name, id) do
        name = Moongate.Core.atom_to_string(module_name)

        %{
          id: id,
          name: name,
          zone: Moongate.Zone.Service.zone_module(module_name)
        }
        |> Moongate.Network.register(:zone, "#{name}_#{id}")
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

  defmodule Void do
  end
end
