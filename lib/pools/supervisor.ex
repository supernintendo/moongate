defmodule Moongate.Pools.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :pool])
  end

  @doc """
    Prepare the pools listener supervisor.
  """
  def init(_) do
    children = [worker(Moongate.Pools.Pool, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
