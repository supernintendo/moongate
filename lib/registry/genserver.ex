defmodule Moongate.Registry.GenServer do
  @moduledoc """
    Used to communicate with processes within the main
    supervisor.
  """
  use GenServer
  use Moongate.Core

  @doc """
    Start the process registry with a new ETS table
    for storing processes.
  """
  def start_link do
    %Moongate.Registry{
      registry: :ets.new(:registry,
        [
          :named_table,
          :public,
          {:read_concurrency, true},
          {:write_concurrency, true},
        ]
      )
    }
    |> establish
  end

  @doc """
    This is called after start_link has resolved.
  """
  def init(state) do
    {:ok, state}
  end

  def handle_call({:shutdown}, _from, _state) do
  end
end
