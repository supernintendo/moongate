defmodule Moongate.Sockets.HTTP.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :http_hosts])
  end

  @doc """
    Prepare the sockets listener supervisor.
  """
  def init(_) do
    children = [worker(Moongate.HTTP.Host, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
