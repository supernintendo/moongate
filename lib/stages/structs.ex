defmodule Moongate.StageEvent do
  defstruct(
    from: nil,
    mutations: [],
    origin: nil,
    params: nil
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Data, as: :into
  end
end

defmodule Moongate.StageInstance do
  defstruct(
    events: %{},
    id: nil,
    members: [],
    pools: [],
    stage: nil
  )
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Data, as: :into
  end
end
