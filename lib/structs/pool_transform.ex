defmodule Moongate.PoolTransform do
  @moduledoc """
    Represents a transformation of one of a pool
    member's attributes over time.
  """
  defstruct(
    by: 0,
    mode: "linear",
    time_started: nil
  )
end
