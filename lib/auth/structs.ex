defmodule Moongate.Auth.GenServer.State do
  @moduledoc """
    Represents the state of the Moongate.Auth GenServer.
    `sessions` is a map of Moongate.AuthSessions with the
    of ids of each Moongate.Origin as keys.
  """
  defstruct anonymous: false, sessions: %{}
end

defmodule Moongate.AuthSession do
  @moduledoc """
    Represents a single auth session.
  """
  defstruct email: nil, identity: "anon"
end
