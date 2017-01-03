defmodule Moongate.ZoneState do
  @moduledoc """
  Represents the state of a Moongate.Zone.
  """

  defstruct(
    __mutation_module: Moongate.ZoneMutations,
    __pending_mutations: [],
    id: nil,
    members: %{},
    rings: [],
    name: "Untitled",
    zone: nil
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.CoreState, as: :into
  end
end