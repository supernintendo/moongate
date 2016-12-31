defmodule Moongate.Packets.Operations do
  use Moongate.Packets.Metadata

  def all, do: packet_operations
  def by_key, do: packet_operations.by_key
  def by_index, do: packet_operations.by_index
end
