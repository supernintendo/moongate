defmodule Moongate.Web.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :web])
  end

  def init(_) do
    [worker(Moongate.Web.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
