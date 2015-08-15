defmodule Moongate.Sockets.Web.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :web_sockets])
  end

  @doc """
    Prepare the sockets listener supervisor.
  """
  def init(_) do
    children = [worker(Moongate.Sockets.Web.Socket, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
