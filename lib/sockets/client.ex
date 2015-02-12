defmodule Sockets.Client do
  use Mixins.Packets
  use GenServer
  
  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def init do
    {:ok, []}
  end
end
