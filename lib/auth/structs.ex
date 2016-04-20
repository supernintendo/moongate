defmodule Moongate.Auth.GenServer.State do
  @moduledoc """
    Represents the state of the auth process. Every
    key in `sessions` represents the id of a socket
    origin.
  """
  defstruct anonymous: false, sessions: %{}
end

defmodule Moongate.AuthSession do
  @moduledoc """
    Represents a single auth session.
  """
  defstruct email: nil, identity: "anon"
end
