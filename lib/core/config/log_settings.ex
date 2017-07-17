defmodule Moongate.CoreConfig.LogSettings do
  defstruct(
    error: true,
    fiber: false,
    info: true,
    packet: false,
    ring: false,
    session: false,
    socket: true,
    zone: false,
    warning: true
  )
end
