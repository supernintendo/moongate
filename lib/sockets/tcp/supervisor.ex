defmodule Moongate.Socket.TCP.Supervisor do
  @moduledoc """
    This is a supervisor for a TCP packet listener. When
    Moongate starts, the ports.json of the active world is
    loaded and a process is added to this supervisor for
    every object with `protocol` set to `"TCP"`. The key
    of the object is used as the process' port.
  """
  use Supervisor

  @doc """
    Start the TCP packet listener supervisor.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :tcp])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.Socket.TCP.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
