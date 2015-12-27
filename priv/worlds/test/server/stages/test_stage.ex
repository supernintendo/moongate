defmodule Test.Stage.TestStage do
  import Moongate.Stage

  meta %{}
  pools []
  takes :test_message, :test_callback

  def arrival(event) do
    :ok
  end

  def test_callback(event, params) do
    :ok
  end
end
