defmodule Moongate.SocketOrigin do
  defstruct(
    auth: %Moongate.AuthSession{email: nil, identity: "anon"},
    events_listener: nil,
    id: nil,
    ip: nil,
    port: nil,
    protocol: nil
  )
end
