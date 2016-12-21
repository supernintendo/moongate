defmodule Moongate.Logger do
  use GenServer

  def start_link do
    %{}
    |> Moongate.Network.establish("logger", __MODULE__)
  end

  def handle_cast({:log, message}, state) do
    Moongate.Logger.Service.log(message)

    {:noreply, state}
  end

  def handle_cast({:log, message, status}, state) do
    Moongate.Logger.Service.log({message, status})

    {:noreply, state}
  end
end
