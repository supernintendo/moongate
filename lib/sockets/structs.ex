defmodule Moongate.Origin do
  @moduledoc """
    Represents a client.
  """
  defstruct(
    auth: %Moongate.AuthSession{email: nil, identity: "anon"},
    events: nil,
    id: nil,
    ip: nil,
    port: nil,
    protocol: nil
  )
end

defmodule Moongate.Socket.GenServer.State do
  @moduledoc """
    Represents the state of a socket listener, regardless
    of protocol.
  """
  defstruct port: nil
end
