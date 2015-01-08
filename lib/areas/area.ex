defmodule Area.State do
  defstruct default: false,
            entities: %{},
            generator: nil,
            id: nil,
            spec: nil,
            started: nil,
            process: nil,
            x: nil,
            y: nil
end

defmodule Area do
  use GenServer
  use Mixins.SocketWriter
  use Mixins.Store

  def start_link(params) do
    process_name = String.to_atom("area_#{params.id}")
    GenServer.start_link(__MODULE__, Map.merge(%Area.State{}, params), [name: process_name])
  end

  def handle_cast({:init}, state) do
    Say.pretty("Area with id #{state.id} created.", :blue)
    {:noreply, state}
  end

  def handle_cast({:join, origin}, state) do
    id = String.to_atom("entity_" <> UUID.uuid4(:hex))
    updated = set_in(state, :entities, id, new_entity(origin))
    {:noreply, updated}
  end

  def handle_cast({:tell, origin}, state) do
    # tiles = Enum.reduce("", &serialize_tiles(&1, &2, state))
    {:noreply, state}
  end

  defp new_entity(controller) do
    %Entity.State{
      controller: controller,
      x: 0,
      y: 0
    }
  end
end