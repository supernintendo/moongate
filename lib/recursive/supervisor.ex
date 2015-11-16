defmodule Moongate.Recursive.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :recursive])
  end

  @doc """
    Prepare the HTTP server supervisor.
  """
  def init(_) do
    children = [worker(Moongate.Recursive, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
