defmodule Moongate.Stage.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :stage])
  end

  @doc """
    Prepare the event listener supervisor.
  """
  def init(_) do
    [worker(Moongate.Stage.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
