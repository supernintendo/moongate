defmodule Moongate.CoreConfig.LogSettings do
  defstruct(
    error: true,
    fiber: true,
    info: true,
    packet: false,
    ring: true,
    session: true,
    socket: true,
    zone: true,
    warning: true
  )
end
