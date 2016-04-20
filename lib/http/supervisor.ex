defmodule Moongate.HTTP.Supervisor do
  @moduledoc """
    This is a supervisor for a simple HTTP server. When
    Moongate starts, the ports.json of the active world is
    loaded and a process is added to this supervisor for
    every object with `protocol` set to `"HTTP"`. The key
    of the object is used as the process' port.
  """
  use Supervisor

  @doc """
    Start the HTTP listener supervisor.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :http])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.HTTP.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
