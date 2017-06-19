defmodule Moongate.CorePool do
  alias Moongate.CoreDispatcher
  use Supervisor

  @pool_options [
    name: {:local, :dispatcher},
    worker_module: CoreDispatcher,
    size: 24,
    max_overflow: 8
  ]

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :pool])
  end

  def init(_) do
    children = [:poolboy.child_spec(:dispatcher, @pool_options, [])]
    supervise(children, strategy: :one_for_one)
  end
end