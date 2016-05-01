defmodule Moongate.StageEvent do
  @moduledoc """
    Represents a stage event. `into` is
    implemented to allow the use of mutations.
  """
  defstruct(
    __moongate_mutations: [],
    from: nil,
    origin: nil,
    params: nil
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Macros.Mutations, as: :into
  end
end

defmodule Moongate.Stage.GenServer.State do
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
    defdelegate into(original), to: Moongate.Macros.Mutations, as: :into
  end
end
