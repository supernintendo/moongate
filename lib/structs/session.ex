defmodule Moongate.Session do
  @moduledoc """
    Represents the state of an event process. `into` is
    implemented to allow the use of mutations.
  """
  defstruct id: nil, origin: nil, zones: [], target_zone: nil
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Mutations, as: :into
  end
end
