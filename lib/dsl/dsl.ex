defmodule Moongate.DSL do
  defmacro __using__(type) do
    type_module = (fn ->
      case type do
        :deed -> Moongate.DSL.TermSets.Deed
        :ring -> Moongate.DSL.TermSets.Ring
        :zone -> Moongate.DSL.TermSets.Zone
        _ -> Moongate.DSL.Void
      end
    end).()

    quote do
      use Moongate.CoreState
      import unquote(type_module)

      @default_id "$"

      @doc """
      Gets the current value of a pool member attribute
      by key.
      """
      def get(member, key), do: Moongate.RingService.member_attr(member, key)

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
      def push_state(%Moongate.CoreEvent{} = event, {key, value}) when is_function(value) do
        for target <- event.targets do
          push_state(target, {key, apply(value, [target])})
        end
        event
      end
      def push_state(%Moongate.CoreEvent{} = event, transaction) do
        for target <- event.targets do
          push_state(target, transaction)
        end
        event
      end
      def push_state(%Moongate.CoreOrigin{} = target, transaction) do
        %Moongate.CorePacket{
          body: Enum.into([transaction], %{}),
          domain: :state
        }
        |> Moongate.CoreNetwork.send_packet(target)

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
          zone: Moongate.ZoneService.zone_module(module_name)
        }
        |> Moongate.CoreNetwork.register(:zone, "#{name}_#{id}")
      end
    end
  end

  defmodule Void do
  end
end
