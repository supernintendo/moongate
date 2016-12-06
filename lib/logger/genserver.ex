defmodule Moongate.Logger do
  use GenServer

  def start_link do
    %{}
    |> Moongate.Network.establish("logger", __MODULE__)
  end

  def handle_cast({:init}, state) do
    {:noreply, state}
  end

  def handle_cast({:log, status, message}, state) do
    Moongate.Logger.Service.log(status, message)

    {:noreply, state}
  end
end
