defmodule Moongate.ClientEvent do
  @moduledoc """
    A structured representation of a packet message,
    after it has been parsed and made sense of. This
    is usually what gets passed around in the DSL-enabled
    modules of a Moongate world.
  """
  defstruct(
    cast: nil,
    error: nil,
    from: nil,
    __moongate_mutations: [],
    origin: nil,
    params: nil,
    to: nil,
    use_deed: nil
  )
end

defmodule Moongate.Event.GenServer.State do
  @moduledoc """
    Represents the state of an event process. `into` is
    implemented to allow the use of mutations.
  """
  defstruct id: nil, origin: nil, stages: [], target_stage: nil
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Macros.Mutations, as: :into
  end
end
