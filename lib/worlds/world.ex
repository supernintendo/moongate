defmodule World do
  use GenServer
  use Mixins.AreaResolver
  use Mixins.Store

  def start_link(config) do
    params = %{
      areas: resolve_areas(config["areas"]),
      id: config["id"],
      name: config["name"]
    }
    process_name = String.to_atom("world_#{params.id}")
    GenServer.start_link(__MODULE__, Map.merge(%World.State{}, params), [name: process_name])
  end

  def handle_cast({:init}, state) do
    Say.pretty("World '#{state.name}' created.", :blue)
    {:noreply, state}
  end

  def handle_cast({:join, event}, state) do
    area_to_join = Enum.find(state.areas, &get_default_area(&1))
    updated = state

    if area_to_join do
      GenServer.cast(area_to_join.process, {:join, event.origin})
      GenServer.cast(area_to_join.process, {:tell, event.origin})
      updated = set_in(updated, :origins, String.to_atom(":origin_#{event.origin.id}"), event.origin)
    end

    {:noreply, updated}
  end

  def handle_cast({:init_all_inactive_areas}, state) do
    {:noreply, state}
  end

  def handle_call(:give_info, _from, state) do
    {:reply, "#{state.id};#{state.name}", state}
  end

  def handle_cast({:keypress, event}, state) do
    GenServer.cast(String.to_atom("entity_#{event.origin.id}"), {:keypress, event.contents.key})
    {:noreply, state}
  end

  def handle_cast({:spawn_all_areas}, state) do
    updated = Map.merge(state, %{areas: Enum.map(state.areas, &start_area(&1))})
    {:noreply, updated}
  end

  # Get the default area
  defp get_default_area(area) do
    area.default
  end

  # Spawn process for an area and return its attributes with the spec
  # removed and the pid included.
  defp start_area(area) do
    {:ok, pid} = GenServer.call(:tree, {:spawn, :areas, area.spec})
    mark_area_as_started(area, pid)
  end
end
