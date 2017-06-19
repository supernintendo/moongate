defmodule Moongate.CoreConfig.Log do
  alias Moongate.CoreConfig.LogSettings

  defstruct(
    console: %LogSettings{},
    default: %LogSettings{}
  )
end
