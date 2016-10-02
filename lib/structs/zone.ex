defmodule Moongate.Zone do
  @moduledoc """
    Represents the state of a zone process. `into` is
    implemented to allow the use of mutations.
  """
  defstruct(
    id: nil,
    members: [],
    rings: [],
    zone: nil
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Mutations, as: :into
  end
end
