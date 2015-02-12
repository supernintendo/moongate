defmodule Entity.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :entities])
  end

  @doc """
    Prepare the entities supervisor.
  """
  def init(params) do
    children = [worker(Entity.Process, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end