defmodule Moongate.ZoneState do
  @moduledoc """
  Represents the state of a Moongate.Zone.
  """

  defstruct(
    id: nil,
    members: %{},
    rings: [],
    name: "Untitled",
    zone: nil,
    zone_params: %{}
  )
end
