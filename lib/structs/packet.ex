defmodule Moongate.Packet do
  @moduledoc """
    A structured representation of a packet message,
    after it has been parsed and made sense of. This
    is usually what gets passed around in the DSL-enabled
    modules of a Moongate world.
  """
  defstruct(
    __moongate_mutations: [],
    cast: nil,
    error: nil,
    from: nil,
    origin: nil,
    params: nil,
    to: nil,
    use_deed: nil
  )
end
