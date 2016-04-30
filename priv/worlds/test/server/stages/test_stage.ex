defmodule Test.Stage.TestStage do
  import Moongate.Stage
  import Moongate.Macros.SocketWriter

  meta %{}
  pools []

  def arrival(event) do
    event
  end
end
