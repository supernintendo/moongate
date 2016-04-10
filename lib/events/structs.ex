defmodule Moongate.ClientEvent do
  @moduledoc """
    Represents a Moongate.Events.Listener's SocketOrigin,
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

defmodule Moongate.EventListener do
  @moduledoc """
    Represents the state of a Moongate.Events.Listener
    GenServer.
  """
  defstruct id: nil, origin: nil, stages: [], target_stage: nil
  defimpl Collectable do
    defdelegate into(original), to: Moongate.Data, as: :into
  end
end
