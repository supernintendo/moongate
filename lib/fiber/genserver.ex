defmodule Moongate.Fiber.GenServer do
  use GenServer

  def start_link({name, params}) do
    %Moongate.Fiber{}
    |> Map.merge(params)
    |> Moongate.Network.establish("fiber", "#{name}", __MODULE__)
  end

  def handle_cast(:init, state) do
    handler = spawn(state.fiber_module, :start, fiber_params(state.params) ++ [self])
    Moongate.Core.log({:socket, "Fiber (#{Moongate.Core.module_to_string(state.fiber_module)})"}, :up)

    {:noreply, %{state | handler: handler}}
  end

  defp fiber_params(params) do
    case params do
      nil -> []
      _ -> params
    end
  end
end
