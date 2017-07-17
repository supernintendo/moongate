defmodule Moongate.SocketState do
  @moduledoc """
  Represents the state of a Moongate.Socket.
  """

  defstruct(
    handler_module: nil,
    port: nil,
    public: "static",
    protocol: nil,
    socket: nil
  )
  @protocols ~w(udp web)a
  @types %{
    port: Integer,
    public: String,
    protocol: {Atom, @protocols}
  }
  def types, do: @types
end
