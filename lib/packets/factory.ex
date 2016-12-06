defmodule Moongate.Packets.Factory do
  use Moongate.Packets.Metadata

  def operations, do: packet_operations
  def operations_by_key, do: packet_operations.by_key
  def operations_by_index, do: packet_operations.by_index
end
