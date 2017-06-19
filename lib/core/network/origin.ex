defmodule Moongate.CoreOrigin do
  @moduledoc """
  Represents a client.
  """

  defstruct(
    id: nil,
    ip: nil,
    port: nil,
    protocol: nil
  )
end
