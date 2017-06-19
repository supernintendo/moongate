defmodule Moongate.LoggerState do
  defstruct(
    logger_mode: :console,
    log: %{}
  )
  @logger_modes ~w(console default none)a
  @types %{
    logger_mode: {Atom, @logger_modes}
  }
  def types, do: @types
end
