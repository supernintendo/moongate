defmodule Moongate.Dispatcher.GenServer do
  use GenServer
  use Moongate.Macros.Processes

  @moduledoc """
    Provides functionality for a packet dispatcher.
  """

  ### Public

  @doc """
    Start the packet dispatcher.
  """
  def start_link(origin) do
    %{}
    |> link
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    state
    |> no_reply
  end
end
