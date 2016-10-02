defmodule Moongate.Ring do
  @moduledoc """
    Represents the state of a ring process. `into` is
    implemented to allow the use of mutations.
  """
  defstruct(
    __moongate_mutations: [],
    attributes: %{},
    index: 0,
    members: [],
    name: nil,
    spec: nil,
    zone: nil,
    subscribers: []
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Mutations, as: :into
  end
end
