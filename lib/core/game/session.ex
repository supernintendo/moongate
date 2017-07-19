defmodule Moongate.CoreSession do
  @moduledoc """
  Represents a client session.
  """

  defstruct(
    access: [],
    key: "",
    origin: %Moongate.CoreOrigin{},
    port: nil,
    tags: []
  )
end
