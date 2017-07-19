defmodule Moongate.FiberState do
  @moduledoc """
  Represents the state of a Moongate.Fiber.
  """

  defstruct(
    command: nil,
    fiber_module: nil,
    handler: nil,
    params: %{}
  )
end
