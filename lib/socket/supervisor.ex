defmodule Moongate.SocketSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :socket])
  end

  def init(_) do
    [worker(Moongate.Socket, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
