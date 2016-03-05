defmodule Moongate.Events.Supervisor do
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
    Supervisor.start_link(__MODULE__, nil, [name: :events])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    children = [worker(Moongate.Events.Listener, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
