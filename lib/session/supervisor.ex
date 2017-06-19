defmodule Moongate.SessionSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :session])
  end

  def init(_) do
    [worker(Moongate.Session, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
