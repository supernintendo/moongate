defmodule Moongate.CoreEvent do
  @moduledoc """
  Provides a data container for events passed to
  functions within world modules - this is the
  fundamental data structure that Moongate's
  DSL relies upon.
  """

  defstruct(
    __pending_mutations: [],
    body: nil,
    deed: nil,
    domain: nil,
    origin: nil,
    ring: nil,
    targets: [],
    zone: nil
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.CoreState, as: :into
  end
end
