defmodule Area.Process do
  use GenServer
  use Mixins.SocketWriter
  use Mixins.Store

  def start_link(params) do
    process_name = String.to_atom("area_#{params.id}")
    GenServer.start_link(__MODULE__, Map.merge(%Area{}, params), [name: process_name])
  end

  def handle_cast({:init}, state) do
    Say.pretty("Area with id #{state.id} created.", :blue)
    {:noreply, state}
  end

  def handle_cast({:enter, entity_id}, state) do
    updated = set_in(state, :entities, String.to_atom(entity_id), %{
      x: 0,
      y: 0
    })
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
      end
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

  defp resolve_move(entity, direction) do
    case direction do
      "up" -> {entity.x, entity.y - 1}
      "down" -> {entity.x, entity.y + 1}
      "left" -> {entity.x - 1, entity.y}
      "right" -> {entity.x + 1, entity.y}
    end
  end

  defp tile_exists(x, y, state) do
    Enum.any?(state.tiles, fn(tile) -> tile.x == x and tile.y == y end)
  end
end