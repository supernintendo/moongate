defmodule Moongate.Packets.Decoder do
  @patterns %{
  	body: ~r/(?<=::).+/,
    deed: ~r/<(.*?)>/,
    domain: ~r/\[(.*?)\]/,
  	ring: ~r/{(.*?)}/,
    zone: ~r/\((.*?)\)/,
  }
  @param_splitter "░"
  @prefix "#"
  @splitter ":"
  @operations Moongate.Packets.Factory.operations_by_index

  def decode(packet) do
  	{packet, []}
  	|> decode_packet(:body)
  	|> decode_packet(:deed)
  	|> decode_packet(:domain)
  	|> decode_packet(:ring)
    |> decode_packet(:zone)
    |> get_decode_result
    |> split_field(:domain)
    |> split_field(:zone)
    |> process_field(:domain)
  end

  def split_body_params(chunk) do
    chunk
    |> String.split(@param_splitter)
    |> List.to_tuple
  end

  def whitelist(collection, list) do
    collection
    |> Enum.filter(fn ({key, _value}) ->
      list |> Enum.any?(&(&1 == key))
    end)
  end

  defp apply_pattern(packet, pattern) do
    case Regex.run(pattern, packet) do
      result when is_list(result) -> List.last(result)
      _ -> nil
    end
  end

  defp decode_opcode(opcode) do
    index =
      opcode
      |> Hexate.to_integer

    Enum.at(@operations, index)
    |> String.to_existing_atom
  end

  defp decode_packet({packet, parts}, pattern_name) do
  	case @patterns[pattern_name] do
      nil -> throw "Moongate: #{pattern_name} is not a valid packet regex name. Check @patterns in lib/packets.ex."
  	  pattern -> {packet, parts ++ [{pattern_name, apply_pattern(packet, pattern)}]}
    end
  end

  defp get_decode_result({_packet, result}) do
    result
    |> Enum.into(%{})
  end

  defp process_field(result, :domain) do
    case result.domain do
      nil -> result
      {opcode, type} -> Map.put(result, :domain, {decode_opcode(opcode), String.to_existing_atom(type)})
      opcode -> Map.put(result, :domain, decode_opcode(opcode))
    end
  end

  defp split_field(result, key) do
    if result[key] && String.contains?(result[key], @splitter) do
      result
      |> Map.update!(key, fn(value) ->
        value
        |> String.split(@splitter)
        |> List.to_tuple
      end)
    else
      result
    end
  end
end
