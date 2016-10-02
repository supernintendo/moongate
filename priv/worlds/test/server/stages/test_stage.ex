defmodule Test.Zone.TestZone do
  import Moongate.Zone
  import Moongate.Macros.SocketWriter

  meta %{}
  rings []

  def arrival(event) do
    event
  end
end
