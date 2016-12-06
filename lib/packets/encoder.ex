defmodule Moongate.Packets.Encoder do
  @boundaries %{
    body: "::",
    deed: {"<", ">"},
    domain: {"[", "]"},
    ring: {"{", "}"},
    zone: {"(", ")"}
  }
  @separator ":"
  @prefix "#"
  @operations Moongate.Packets.Factory.operations_by_key

  def operations, do: @operations

  def encode(packet) do
    @prefix
    <> append_chunk({packet, :domain})
    <> append_chunk({packet, :zone})
    <> append_chunk({packet, :ring})
    <> append_chunk({packet, :deed})
    <> append_chunk({packet, :body})
  end

  defp append_chunk({packet, key}) do
    case Map.get(packet, key) do
      nil -> ""
      {value, index} -> padded_chunk({{value, index}, key})
      value -> padded_chunk({value, key})
    end
  end

  defp padded_chunk({chunk, :body}) do
    "#{@boundaries.body}#{prepare_body(chunk)}"
  end
  defp padded_chunk({{value, index}, :domain}) do
    {left, right} = @boundaries.domain

    "#{left}#{Hexate.encode(@operations[value], 2)}#{@separator}#{index}#{right}"
  end
  defp padded_chunk({value, :domain}) do
    {left, right} = @boundaries.domain

    "#{left}#{Hexate.encode(@operations[value], 2)}#{right}"
  end
  defp padded_chunk({{value, index}, key}) do
    {left, right} = @boundaries[key]

    "#{left}#{value}#{@separator}#{index}#{right}"
  end
  defp padded_chunk({value, key}) do
    {left, right} = @boundaries[key]

    "#{left}#{value}#{right}"
  end

  defp prepare_body(chunk) when is_list(chunk), do: Enum.join(chunk, ",")
  defp prepare_body(chunk) when is_map(chunk) do
    Poison.encode!(chunk)
  end
  defp prepare_body(chunk), do: chunk
end
