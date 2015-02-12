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
end