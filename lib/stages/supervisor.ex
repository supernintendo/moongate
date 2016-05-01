defmodule Moongate.Stage.Supervisor do
  @moduledoc """
    This is a supervisor for stagel processes. For every stage
    defined within a world, a process is created within this
    supervisor.
  """
  use Supervisor

  @doc """
    Start the stage process supervisor.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :stage])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.Stage.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
