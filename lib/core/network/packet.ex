defmodule Moongate.CorePacket do
  @moduledoc """
  Represents a packet before it has been encoded.
  """

  defstruct(
    body: nil,
    handler: nil,
    ring: nil,
    rule: nil,
    zone: nil,
    zone_id: nil
  )
end
