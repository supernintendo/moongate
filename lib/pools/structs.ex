defmodule Moongate.Pool.GenServer.State do
  @moduledoc """
    Represents the state of a pool process.
  """
  defstruct(
    attributes: %{},
    index: 0,
    members: [],
    name: nil,
    spec: nil,
    stage: nil,
    subscribers: []
  )
end

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
