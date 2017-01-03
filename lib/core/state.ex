defmodule Moongate.CoreState do
  defmacro __using__(type) do
    quote do
      if unquote(type == :server) do
        def commit_mutation(event, state) do
          commit_mutation(event, state, state.__mutation_module)
        end
        def commit_mutation(event, state, mutation_module) do
          event.__pending_mutations
          |> Enum.sort(fn ({time_a, _}, {time_b, _}) -> time_a < time_b end)
          |> Enum.reduce({event, state}, fn({_timestamp, mut}, {current_event, current_state}) ->
            prepared_event =
              current_event
              |> Map.put(:__pending_mutations, Enum.filter(current_event.__pending_mutations, &(&1 != mut)))

            {mutation_result, event_result} =
              apply(mutation_module, :mutate, [mut, prepared_event, current_state])

            case mutation_result do
              mutation_result when is_list(mutation_result) ->
                {event_result, Enum.into(mutation_result, current_state)}
              {_key, _value} ->
                {event_result, Enum.into([mutation_result], current_state)}
              nil ->
                {event_result, current_state}
            end
          end)
          |> elem(1)
        end

        def handle_call({:mutations, event}, _from, state) do
          state = event |> commit_mutation(state)

          {:reply, :ok, state}
        end
      end

      def mutate(map, value) do
        timestamp = :os.system_time(:nano_seconds)

        %{map | __pending_mutations: map.__pending_mutations ++ [{timestamp, value}]}
      end

      def new_event(%Moongate.RingState{} = state, params) do
        %Moongate.CoreEvent{
          __pending_mutations: state.__pending_mutations,
          ring: state.name,
          zone: {state.zone, state.zone_id}
        }
        |> Map.merge(params)
      end

      def new_event(%Moongate.ZoneState{} = state, params) do
        %Moongate.CoreEvent{
          __pending_mutations: state.__pending_mutations,
          zone: {state.name, state.id}
        }
        |> Map.merge(params)
      end

      defoverridable [mutate: 2]
    end
  end

  def into(original) do
    {original, fn
      map, {:cont, {k, v}} ->
        :maps.put(k, v, map)
      map, :done -> map
    _, :halt -> :ok
    end}
  end
end
