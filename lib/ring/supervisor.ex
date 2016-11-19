defmodule Moongate.Ring.Supervisor do
  @moduledoc """
    Supervisor for Moongate.Ring.GenServer. Follows the
    simple_one_for_one strategy.
  """
  use Supervisor

  @doc """
    This is called when the supervision tree initializes.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :ring])
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(_) do
    [worker(Moongate.Ring.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
