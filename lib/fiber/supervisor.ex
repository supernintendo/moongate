defmodule Moongate.FiberSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :fiber])
  end

  def init(_) do
    [worker(Moongate.Fiber, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
