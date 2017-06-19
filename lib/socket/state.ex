defmodule Moongate.SocketState do
  @moduledoc """
  Represents the state of a Moongate.Socket.
  """

  defstruct(
    handler_pid: nil,
    port: nil,
    public: "static",
    protocol: nil
  )
  @protocols ~w(web)a
  @types %{
    port: Integer,
    public: String,
    protocol: {Atom, @protocols}
  }
  def types, do: @types
end
