defmodule Moongate.RingState do
  @moduledoc """
  Represents the state of a Moongate.Ring.
  """

  defstruct(
    __mutation_module: Moongate.RingMutations,
    __pending_mutations: [],
    attributes: %{},
    deeds: %{},
    index: 0,
    members: [],
    name: nil,
    ring: nil,
    zone: nil,
    zone_id: nil,
    subscribers: []
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.CoreState, as: :into
  end
end