defmodule Moongate.CorePacket do
  @moduledoc """
  Represents a packet before it has been encoded.
  """

  defstruct(
    body: nil,
    deed: nil,
    domain: nil,
    ring: nil,
    zone: nil
  )
end