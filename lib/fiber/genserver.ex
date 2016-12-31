defmodule Moongate.Fiber.GenServer do
  use GenServer

  def start_link({name, params}) do
    %Moongate.Fiber{}
    |> Map.merge(params)
    |> Moongate.Network.establish("fiber", "#{name}", __MODULE__)
  end

  def handle_cast(:init, state) do
    handler = spawn(state.fiber_module, :start, (state.params || []) ++ [self])
    Moongate.Core.log({:socket, "Fiber (#{Moongate.Core.atom_to_string(state.fiber_module)})"}, :up)

    {:noreply, %{state | handler: handler}}
  end
end
