defmodule Moongate.RingState do
  @moduledoc """
  Represents the state of a Moongate.Ring.
  """

  defstruct(
    attributes: %{},
    channels: %{},
    events_channel_name: nil,
    index: 0,
    rules: %{},
    members: [],
    members_table_name: nil,
    morphs: %{},
    morphs_table_name: nil,
    name: nil,
    pubsub: nil,
    ring: nil,
    ring_module: nil,
    zone: nil,
    zone_id: nil
  )
end
