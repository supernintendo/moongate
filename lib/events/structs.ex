defmodule Moongate.ClientEvent do
  @moduledoc """
    Represents a Moongate.Event.Listener's SocketOrigin,
    as well as information related to packets received by
    the socket connection.
  """
  defstruct(
    cast: nil,
    error: nil,
    from: nil,
    mutations: [],
    origin: nil,
    params: nil,
    to: nil,
    use_deed: nil
  )
end

defmodule Moongate.Event.GenServer.State do
  @moduledoc """
    Represents the state of a Moongate.Event.GenServer.
  """
  defstruct id: nil, origin: nil, stages: [], target_stage: nil
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Data, as: :into
  end
end
