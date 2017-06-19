defmodule Moongate.Packet do
  alias Moongate.{
    PacketCompressor,
    PacketDecoder,
    PacketEncoder,
    PacketFactory,
    PacketHandler
  }

  def init do
    PacketCompressor.bootstrap()
    :ok
  end

  def atlas do
    %{
      compressor: %{
        by_word: PacketCompressor.by_word(),
        by_token: PacketCompressor.by_token()
      }
    }
  end

  def compressor, do: PacketCompressor
  def decoder, do: PacketDecoder
  def encoder, do: PacketEncoder
  def factory, do: PacketFactory
  def handler, do: PacketHandler
end
