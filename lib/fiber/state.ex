defmodule Moongate.FiberState do
  @moduledoc """
  Represents the state of a Moongate.Fiber.
  """

  defstruct(
    command: nil,
    handler: nil,
    name: nil,
    params: nil,
    parent: nil
  )
end