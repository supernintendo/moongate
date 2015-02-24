defmodule Area.Process do
  use Mixins.Random
  use Mixins.Pool
  use Mixins.SocketWriter
  use Mixins.Store
  use Mixins.Translator

  def start_link(params) do
    seed_random
    link(Map.merge(%Area{}, params), "area", "#{params.id}")
  end

  def handle_cast({:init}, state) do
    Say.pretty("Area with id #{state.id} created.", :blue)
    {:noreply, state}
  end

  def handle_cast({:leave, entity_id}, state) do
    id = String.to_atom(entity_id)
    updated = drop_from(state, :entities, id)

    broadcast_entities_to_all(updated)
    {:noreply, updated}
  end

  def handle_cast({:enter, entity_id}, state) do
    id = String.to_atom(entity_id)
    updated = set_in(state, :entities, id, %{
      id: id,
      x: random_of(8),
      y: random_of(8)
    })
    broadcast_entities_to_all(updated)
    broadcast_tiles_to(entity_id, updated)
    {:noreply, updated}
  end

  def handle_cast({:join, origin}, state) do
    new_entity(origin, state.id)
    {:noreply, state}
  end

  def handle_cast({:move, direction, entity_id}, state) do
    id = String.to_atom(entity_id)
    entity = state.entities[id]
    updated = state

    if entity do
      {x_to_check, y_to_check} = resolve_move(entity, direction)

      if tile_exists(x_to_check, y_to_check, state) do
        updated = set_in(state, :entities, id, %{
          id: id,
          x: x_to_check,
          y: y_to_check
        })
        broadcast_entities_to_all(updated)
      end
      broadcast_tiles_to(entity_id, state)
    end
    {:noreply, updated}
  end

  defp new_entity(origin, area_id) do
    {:ok, entity} = spawn_new(:entity, origin)
    tell_pid_async(entity, {:set_area, area_id})
    entity
  end

  defp broadcast_entities_to_all(state) do
    Enum.map(state.entities, &broadcast_entities_to(&1, state))
  end

  defp broadcast_entities_to(entity, state) do
    id = Atom.to_string(elem(entity, 0))
    tell_async(:entity, id, {
      :notify,
      :entities,
      for_pool(state.entities, [:id, :x, :y])
    })
  end

  defp broadcast_tiles_to(entity_id, state) do
    tell_async(:entity, entity_id, {
      :notify,
      :map,
      for_pool(state.tiles, [:id, :x, :y, :tile])
    })
  end

  defp resolve_move(entity, direction) do
    case direction do
      "w" -> {entity.x, entity.y - 1}
      "a" -> {entity.x - 1, entity.y}
      "s" -> {entity.x, entity.y + 1}
      "d" -> {entity.x + 1, entity.y}
    end
  end

  defp tile_exists(x, y, state) do
    Enum.any?(state.tiles, fn(tile) -> tile.x == x and tile.y == y end)
  end
end