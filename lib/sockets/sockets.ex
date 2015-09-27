defmodule Moongate.SocketOrigin do
  defstruct auth: %Moongate.AuthToken{email: nil, identity: "anon"}, id: nil, ip: nil, port: nil, protocol: nil
end
