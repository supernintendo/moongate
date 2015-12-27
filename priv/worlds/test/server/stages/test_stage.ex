defmodule Test.Stage.TestStage do
  import Moongate.Stage
  import Moongate.Macros.SocketWriter

  meta %{}
  pools []
  takes :test_message, :test_callback

  def arrival(event) do
    :ok
  end

  def test_callback(event, _) do
    write_to(event.origin, :test_stage, "Hear you, loud and clear!")
    :ok
  end
end
