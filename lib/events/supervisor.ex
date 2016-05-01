defmodule Moongate.Event.Supervisor do
  @moduledoc """
    This is a supervisor for event processes. Every client
    that connects to the server effectively adds a process
    to this supervisor. Processes within this supervisor
    are responsible for receiving and sending messages to
    and from a client.
  """
  use Supervisor

  @doc """
    Start the event process supervisor.
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
