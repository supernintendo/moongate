defmodule Moongate.Stages.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :stages])
  end

  @doc """
    Prepare the events listener supervisor.
  """
  def init(_) do
    children = [worker(Moongate.Stages.Instance, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
