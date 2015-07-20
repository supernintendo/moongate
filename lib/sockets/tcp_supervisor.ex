defmodule Sockets.TCPSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :tcp_sockets])
  end

  @doc """
    Prepare the sockets listener supervisor.
  """
  def init(_) do
    children = [worker(Sockets.TCPSocket, [], [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end
