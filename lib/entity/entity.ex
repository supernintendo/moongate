defmodule Entity.Process do
  use Timex
  use Mixins.SocketWriter
  use Mixins.Translator

  def start_link(origin) do
    link(%Entity{origin: origin}, "entity", "#{origin.id}")
  end

  def handle_cast({:init}, state) do
    Say.pretty("Entity controlled by #{state.origin.id} spawned.", :blue)
    {:noreply, state}
  end

  def handle_cast({:disconnect}, state) do
    if state.area_id do
      tell_async(:area, state.area_id, {:leave, state.origin.id})
    end

    kill_by_pid(:entity, self())
    {:noreply, nil}
  end

  def handle_cast({:keypress, event}, state) do
    key = event.contents.key
    updated = state

    if state.area_id do
      if (key == "w" or key == "a" or key == "s" or key == "d") and can_move(state.last_move_time) do
        tell_async(:area, state.area_id, {:move, key, state.origin.id})

        updated = Map.put(updated, :last_move_time, Time.now(:msecs))
      end
    end

    {:noreply, updated}
  end

  def handle_cast({:set_area, area_id}, state) do
    if state.area_id do
      tell_async(:area, state.area_id, {:leave, state.origin.id})
    end

    tell_async(:area, area_id, {:enter, state.origin.id})
    {:noreply, Map.put(state, :area_id, area_id)}
  end

  def handle_cast({:notify, namespace, message}, state) do
    write_to(state.origin, %{
      cast: :update,
      namespace: namespace,
      value: message
    })
    {:noreply, state}
  end

  def can_move(last_move_time) do
    if last_move_time do
      (Time.now(:msecs) - last_move_time) >= 75
    else
      true
    end
  end
end