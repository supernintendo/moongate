defmodule Moongate.ZoneEvent do
  @moduledoc """
    Represents a zone event. `into` is
    implemented to allow the use of mutations.
  """
  defstruct(
    __moongate_mutations: [],
    from: nil,
    origin: nil,
    params: nil
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Mutations, as: :into
  end
end
