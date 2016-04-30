defmodule Moongate.Pool.GenServer.State do
  @moduledoc """
    Represents the state of a pool process. `into` is
    implemented to allow the use of mutations.
  """
  defstruct(
    __moongate_mutations: [],
    attributes: %{},
    index: 0,
    members: [],
    name: nil,
    spec: nil,
    stage: nil,
    subscribers: []
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Macros.Mutations, as: :into
  end
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
