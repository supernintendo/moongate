defmodule Moongate.FiberState do
  @moduledoc """
  Represents the state of a Moongate.Fiber.
  """

  defstruct(
    fiber_module: nil,
    handler: nil,
    params: %{}
  )
end
