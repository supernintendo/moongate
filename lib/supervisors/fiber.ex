defmodule Moongate.Fiber.Supervisor do
  @moduledoc """
    Supervisor for Moongate.Fiber.Node. Follows the
    simple_one_for_one strategy.
  """
  use Supervisor

  @doc """
    This is called when the supervision tree initializes.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :fiber])
  end

  @doc """
  This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.Fiber.Node, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
