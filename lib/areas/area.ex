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

  def handle_cast({:join, origin}, state) do
    updated = set_in(state, :entities, String.to_atom(":entity_#{origin.id}"), new_entity(origin))
    {:noreply, updated}
  end

  def handle_cast({:tell, origin}, state) do
    IO.inspect(state)
    # tiles = Enum.reduce("", &serialize_tiles(&1, &2, state))
    {:noreply, state}
  end

  defp new_entity(origin) do
    {:ok, entity} = GenServer.call(:tree, {:spawn, :entities, origin})
    entity
  end
end