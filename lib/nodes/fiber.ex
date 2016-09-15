defmodule Moongate.Fiber.Node do
  use GenServer
  use Moongate.OS

  @doc """
    Start the Fiber server.
  """
  def start_link({name, command}) do
    %Moongate.Fiber{
      command: command,
      name: name,
    }
    |> establish("fiber", "#{name}")
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    proc = %Porcelain.Process{pid: pid} = Porcelain.spawn_shell(state.command)

    log(:up, {:fiber, "Fiber ('#{state.name}')"})
    {:noreply, Map.put(state, :process, proc)}
  end
end