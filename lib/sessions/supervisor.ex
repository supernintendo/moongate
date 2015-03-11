defmodule Sessions.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :sessions])
  end

  @doc """
    Prepare the sessions supervisor.
  """
  def init(_) do
    children = [worker(Session, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
