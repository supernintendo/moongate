defmodule Moongate.Pool.Supervisor do
  @moduledoc """
    This is a supervisor for pool processes. For every pool
    defined within stages in a world, a process is created
    within this supervisor.
  """
  use Supervisor

  @doc """
    Start the pool process supervisor.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :pool])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.Pool.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
