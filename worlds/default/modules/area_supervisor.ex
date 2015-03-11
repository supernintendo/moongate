defmodule Areas.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :areas])
  end

  @doc """
    Prepare the areas supervisor.
  """
  def init(params) do
    _ = params
    children = [worker(Area.Process, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
