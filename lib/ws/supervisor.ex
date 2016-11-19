defmodule Moongate.WebSocket.Supervisor do
  @moduledoc """
    Supervisor for Moongate.WebSocket.GenServer. Follows
    the simple_one_for_one strategy.
  """
  use Supervisor

  @doc """
    This is called when the supervision tree initializes.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :ws])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.WebSocket.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
