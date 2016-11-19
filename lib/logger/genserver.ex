defmodule Moongate.Logger.GenServer do
  @moduledoc """
    Provides a server for logging events.
  """
  use GenServer
  use Moongate.Core

  def start_link do
    nil |> establish("logger")
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, _state) do
    {:noreply, nil}
  end

  def handle_cast({:log, status, message}, _state) do
    Moongate.Logger.Service.log(status, message)

    {:noreply, nil}
  end
end
