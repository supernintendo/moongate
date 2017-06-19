defmodule Moongate.Fiber do
  use GenServer

  def start_link(params, _name) do
    state =
      %Moongate.FiberState{}
      |> Map.merge(params)

    GenServer.start_link(__MODULE__, state)
  end

  def handle_cast(:init, state) do
    handler = spawn(state.fiber_module, :start, [state.params]++ [self()])
    Moongate.Core.log({:fiber, "Fiber (#{inspect state.fiber_module})"}, :up)

    {:noreply, %{state | handler: handler}}
  end
end
