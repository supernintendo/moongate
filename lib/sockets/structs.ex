defmodule Moongate.Origin do
  defstruct(
    auth: %Moongate.AuthSession{email: nil, identity: "anon"},
    event_listener: nil,
    id: nil,
    ip: nil,
    port: nil,
    protocol: nil
  )
end

defmodule Moongate.Socket.GenServer.State do
  defstruct port: nil
end
