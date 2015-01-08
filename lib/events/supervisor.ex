defmodule Events.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :events])
  end

  @doc """
    Prepare the events listener supervisor.
  """
  def init(params) do
    children = [worker(Events.Listener, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
