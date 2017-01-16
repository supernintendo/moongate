defmodule Moongate.PacketsDecoder do
  @patterns %{
    body: ~r/(?<=::).+/,
    deed: ~r/<(.*?)>/,
    domain: ~r/\[(.*?)\]/,
    ring: ~r/{(.*?)}/,
    zone: ~r/\((.*?)\)/,
  }
  @param_delimiter "░"
  @splitter ":"
  @operations Moongate.Packets.operations_by_index

  @doc """
  Modifies a packet string over a series of
  functions, converting it into a map.

  ## Examples
  The following example demonstrates decoding
  a packet which contains all possible fields:

      iex> Moongate.PacketsDecoder.decode("#[01:ring](Foo:$){Bar}<Lorem>::Ipsum")
      %{
        body: "Ipsum",
        deed: "Lorem",
        domain: {:call, :ring},
        ring: "Bar",
        zone: {"Foo", "$"}
      }

  Any field which is not present on the packet
  string will have its corresponding map value
  set to `nil`:

      iex> Moongate.PacketsDecoder.decode("#[04:ring]::ok")
      %{
        body: "ok",
        deed: nil,
        domain: {:respond, :ring},
        ring: nil,
        zone: nil
      }
  """
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

  @doc """
  Splits a string which represents the body
  of a packet over a delimiter, returning the
  list as a tuple so that it can be matched
  against.

      iex> Moongate.PacketsDecoder.split_body_params("128░64")
      {"128", "64"}

      iex> Moongate.PacketsDecoder.split_body_params("32")
      {"32"}

      iex> Moongate.PacketsDecoder.split_body_params("")
      nil

      iex> Moongate.PacketsDecoder.split_body_params(nil)
      nil
  """
  def split_body_params(_chunk = ""), do: nil
  def split_body_params(_chunk = nil), do: nil
  def split_body_params(chunk) do
    chunk
    |> String.split(@param_delimiter)
    |> List.to_tuple
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
      nil ->
        throw "Moongate: #{pattern_name} is not a valid packet regex name. Check @patterns in lib/packets.ex."
      pattern ->
        {packet, parts ++ [{pattern_name, apply_pattern(packet, pattern)}]}
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
