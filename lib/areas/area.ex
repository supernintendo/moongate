defmodule Area.Process do
  use GenServer
  use Mixins.Random
  use Mixins.SocketWriter
  use Mixins.Store

  def start_link(params) do
    seed_random
    process_name = String.to_atom("area_#{params.id}")
    GenServer.start_link(__MODULE__, Map.merge(%Area{}, params), [name: process_name])
  end

  def handle_cast({:init}, state) do
    Say.pretty("Area with id #{state.id} created.", :blue)
    {:noreply, state}
  end

  def handle_cast({:enter, entity_id}, state) do
    updated = set_in(state, :entities, String.to_atom(entity_id), %{
      x: random_of(15),
      y: random_of(15)
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
    entity = state.entities[String.to_atom(entity_id)]
    updated = state

    if entity do
      {x_to_check, y_to_check} = resolve_move(entity, direction)

      if tile_exists(x_to_check, y_to_check, state) do
        IO.puts("Entity #{entity_id} moved to #{x_to_check}, #{y_to_check}.")
        updated = set_in(state, :entities, String.to_atom(entity_id), %{
          x: x_to_check,
          y: y_to_check
        })
        broadcast_entities_to_all(updated)
      end
      broadcast_tiles_to(entity_id, state)
    end
    {:noreply, updated}
  end

  def handle_cast({:tell, origin}, state) do
    # tiles = Enum.reduce("", &serialize_tiles(&1, &2, state))
    {:noreply, state}
  end

  defp new_entity(origin, area_id) do
    {:ok, entity} = GenServer.call(:tree, {:spawn, :entities, origin})
    GenServer.cast(entity, {:set_area, area_id})
    entity
  end

  defp broadcast_entities_to_all(state) do
    Enum.map(state.entities, &broadcast_entities_to(&1, state))
  end

  defp broadcast_entities_to(entity, state) do
    id = Atom.to_string(elem(entity, 0))
    GenServer.cast(String.to_atom("entity_" <> id), {
      :tell_origin,
      :update,
      :entities,
      Enum.reduce(state.entities, "", &serialize_entity(&1, &2))
    })
  end

  defp broadcast_tiles_to(entity_id, state) do
    GenServer.cast(String.to_atom("entity_" <> entity_id), {
      :tell_origin,
      :update,
      :grid,
      Enum.reduce(state.tiles, "", &serialize_tile(&1, &2))
    })
  end

  def serialize_entity(entity, acc) do
    id = Atom.to_string(elem(entity, 0))
    attributes = elem(entity, 1)
    acc <> "#{id};#{attributes.x};#{attributes.y}|"
  end

  def serialize_tile(tile, acc) do
    acc <> "#{tile.x};#{tile.y};#{tile.tile}|"
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