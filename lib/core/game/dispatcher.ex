defmodule Moongate.CoreDispatcher do
  use Supervisor

  @dispatcher Application.get_env(:moongate, :dispatcher)
  @pool_options [
    name: {:local, :dispatcher_pool},
    worker_module: @dispatcher,
    size: 24,
    max_overflow: 8
  ]

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :dispatcher])
  end

  def init(_) do
    children = [:poolboy.child_spec(:dispatcher_pool, @pool_options, [])]
    supervise(children, strategy: :one_for_one)
  end
end
