defmodule Moongate.Fiber.GenServer do
  use GenServer

  def start_link({name, command}) do
    %Moongate.Fiber{
      command: command,
      name: name,
    }
    |> Moongate.Network.establish("fiber", "#{name}", __MODULE__)
  end

  def handle_cast({:init}, state) do
    proc = %Porcelain.Process{pid: _pid} = Porcelain.spawn_shell(state.command)

    Moongate.Core.log(:up, {:fiber, "Fiber ('#{state.name}')"})
    {:noreply, Map.put(state, :process, proc)}
  end
end
