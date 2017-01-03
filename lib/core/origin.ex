defmodule Moongate.CoreOrigin do
  @moduledoc """
  Represents a client.
  """

  defstruct(
    events: nil,
    id: nil,
    ip: nil,
    port: nil,
    protocol: nil
  )
end