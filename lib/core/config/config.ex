defmodule Moongate.CoreConfig do
  alias Moongate.CoreConfig.Client
  alias Moongate.CoreConfig.Log

  defstruct(
    autoreload: true,
    client: %Client{},
    log: %Log{},
    logger_mode: "console",
    endpoints: %{}
  )
end
