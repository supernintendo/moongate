defmodule Moongate.Pool do
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
    defdelegate into(original), to: Moongate.Mutations, as: :into
  end
end
