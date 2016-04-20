defmodule Test.World do
  import Moongate

  stages %{
    test_stage: Test.Stage.TestStage
  }
  def connected(event) do
    arrive event, :test_stage
  end
end
