defmodule Moongate.Stage do
  @moduledoc """
    Represents the state of a stage process. `into` is
    implemented to allow the use of mutations.
  """
  defstruct(
    id: nil,
    members: [],
    pools: [],
    stage: nil
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Mutations, as: :into
  end
end
