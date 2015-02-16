defmodule Entity.Process do
  use GenServer

  def start_link(origin) do
    process_name = String.to_atom("entity_#{origin.id}")
    GenServer.start_link(__MODULE__, %Entity{origin: origin}, [name: process_name])
  end

  def handle_cast({:init}, state) do
    Say.pretty("Entity controlled by #{state.origin.id} spawned.", :blue)
    {:noreply, state}
  end

  def handle_cast({:keypress, event}, state) do
    key = event.contents.key

    if state.area_id do
      if key == "up" or key == "down" or key == "left" or key == "right" do
        GenServer.cast(String.to_atom("area_" <> state.area_id), {:move, key, state.origin.id})
      end
    end

    {:noreply, state}
  end

  def handle_cast({:set_area, area_id}, state) do
    if state.area_id do
      GenServer.cast("area_" <> String.to_atom(state.area_id), {:leave, state.origin.id})
    end

    GenServer.cast(String.to_atom("area_" <> area_id), {:enter, state.origin.id})
    {:noreply, Map.put(state, :area_id, area_id)}
  end
end