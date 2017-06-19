defmodule Moongate.RingSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :ring])
  end

  def init(_) do
    [worker(Moongate.Ring, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
