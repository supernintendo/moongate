defmodule Moongate.RingState do
  @moduledoc """
  Represents the state of a Moongate.Ring.
  """

  defstruct(
    attributes: %{},
    index: 0,
    rules: %{},
    members: [],
    morphs: %{},
    name: nil,
    ring: nil,
    ring_module: nil,
    zone: nil,
    zone_id: nil
  )
end
