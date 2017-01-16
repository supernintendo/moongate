defmodule Moongate.Ring do
  use GenServer
  use Moongate.CoreState, :server

  def start_link(state) do
    state
    |> Moongate.CoreNetwork.establish(__MODULE__)
  end

  def handle_cast(:init, state) do
    Moongate.CoreETS.insert({:ring, state.name, state.attributes})
    Moongate.Core.log({:ring, "Ring (#{state.zone} (#{state.zone_id}) : #{state.name})"}, :up)

    deeds =
      state
      |> apply_on_ring(:__ring_deeds, [])
      |> Enum.map(&({Moongate.Core.atom_to_string(&1), Moongate.Core.project_module(Deed, &1)}))
      |> Enum.into(%{})

    {:noreply, %{state | deeds: deeds}}
  end

  def handle_cast({:subscribe, %Moongate.CoreOrigin{} = origin}, state) do
    case subscribed?(origin, state) do
      false ->
        params = %{origin: origin, targets: [origin]}
        updated_state = mutate(state, {:add_subscriber, origin})

        result =
          updated_state
          |> apply_on_ring(:client_subscribed, [new_event(updated_state, params)])
          |> commit_mutation(state)

        {:noreply, result}
      true ->
        {:noreply, state}
    end
  end

  def handle_cast({:unsubscribe, %Moongate.CoreOrigin{} = origin}, state) do
    params = %{origin: origin, targets: [origin]}
    state =
      state
      |> apply_on_ring(:client_unsubscribed, [new_event(state, params)])
      |> mutate({:remove_subscriber, origin})
      |> commit_mutation(state)

    {:noreply, state}
  end

  def handle_cast({:deed_event, params, event}, state) do
    case state.deeds[event.deed] do
      deed_module when is_atom(deed_module) ->
        {callback, _} = event.domain

        result =
          deed_module
          |> apply_on_deed(callback, [params, event])
          |> commit_mutation(state)

          {:noreply, result}
      _ ->
        {:noreply, state}
    end
  end

  defp subscribed?(origin, state) do
    state.subscribers
    |> Enum.any?(&(&1.id == origin.id))
  end

  defp apply_on_deed(deed_module, function_name, args) do
     apply(deed_module, function_name, args)
  end

  defp apply_on_ring(state, function_name, args) do
    apply(state.ring, function_name, args)
  end
end
