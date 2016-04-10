defmodule Moongate.Event.Supervisor do
  @moduledoc """
    This is a supervisor for Moongate.Events.Listener only. It uses
    the simple_one_for_one strategy, which allows supervised processes
    to be dynamically added and killed.
  """
  use Supervisor

  @doc """
    Start the events listener supervisor.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :event])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.Event.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
