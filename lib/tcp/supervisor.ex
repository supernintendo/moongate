defmodule Moongate.TCP.Supervisor do
  @moduledoc """
    Supervisor for Moongate.TCP.GenServer. Follows the
    simple_one_for_one strategy.
  """
  use Supervisor

  @doc """
    This is called when the supervision tree initializes.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :tcp])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.TCP.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
