defmodule Moongate.Packets do
  use Moongate.PacketsMetadata

  def decoder, do: Moongate.PacketsDecoder
  def encoder, do: Moongate.PacketsEncoder

  def operations, do: packet_operations()
  def operations_by_key, do: packet_operations().by_key
  def operations_by_index, do: packet_operations().by_index
end