defmodule Moongate.ZoneSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :zone])
  end

  def init(_) do
    [worker(Moongate.Zone, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
