defmodule Moongate.RingTransform do
  @moduledoc """
    Represents a transformation of one of a ring
    member's attributes over time.
  """
  defstruct(
    by: 0,
    mode: "linear",
    time_started: nil
  )
end
