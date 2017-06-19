defmodule Moongate.PacketDecoder do
  alias Moongate.{
    CoreTypes,
    NativeModules
  }

  @compressor Application.get_env(:moongate, :packet).compressor
  @delimiter "|"

  @doc """
  Modifies a packet string over a series of
  functions, converting it into a map.

  ## Examples
  The following example demonstrates decoding
  a packet which contains all possible fields:

      iex> Moongate.PacketDecoder.decode("#[01:ring](Foo:$){Bar}<Lorem>::Ipsum")
      %{
        body: "Ipsum",
        rule: "Lorem",
        handler: {:call, :ring},
        ring: "Bar",
        zone: {"Foo", "$"}
      }

  Any field which is not present on the packet
  string will have its corresponding map value
  set to `nil`:

      iex> Moongate.PacketDecoder.decode("#[04:ring]::ok")
      %{
        body: "ok",
        rule: nil,
        handler: {:respond, :ring},
        ring: nil,
        zone: nil
      }
  """
  def decode(packet) do
    {:ok, [zm, rm, cm, hm, bm]} = NativeModules.Packets.decode(packet)

    [body: bm, rule: cm, handler: hm, ring: rm, zone: zm]
    |> Enum.map(fn {key, value} -> {key, typecast(value)} end)
    |> Enum.map(&expand_key_value/1)
    |> Enum.into(%{})
  end


  @doc """
  Splits a string which represents the body
  of a packet over a delimiter, returning the
  list as a tuple so that it can be matched
  against.

      iex> Moongate.PacketDecoder.split_body_params("128|64")
      {"128", "64"}

      iex> Moongate.PacketDecoder.split_body_params("32")
      {"32"}

      iex> Moongate.PacketDecoder.split_body_params("")
      nil

      iex> Moongate.PacketDecoder.split_body_params(nil)
      nil
  """

  def split_body_params(_chunk = ""), do: nil
  def split_body_params(_chunk = nil), do: nil
  def split_body_params(chunk) when is_bitstring(chunk) do
    chunk
    |> String.split(@delimiter)
    |> Enum.map(&typecast/1)
    |> List.to_tuple
  end
  def split_body_params(chunk), do: {chunk}

  defp expand_key_value({:body, value}), do: {:body, value}
  defp expand_key_value({:zone, value}) when is_bitstring(value) do
    if String.contains?(value, ":") do
      {:zone,
        String.split(value, ":")
        |> Enum.take(2)
        |> Enum.map(&typecast/1)
        |> Enum.map(&expand_field/1)
        |> List.to_tuple()}
    else
      {:zone, expand_field(value)}
    end
  end
  defp expand_key_value({key, {value, value_id}}) do
    {key, {expand_field(value), expand_field(value_id)}}
  end
  defp expand_key_value({key, value}), do: {key, expand_field(value)}

  defp expand_field(value) when is_integer(value) do
    expanded_term = @compressor.by_token()[value]

    cond do
      Regex.match?(~r/^[a-z0-9_\-]+$/, expanded_term) ->
        String.to_existing_atom(expanded_term)
      expanded_term ->
        Module.safe_concat([expanded_term])
      true ->
        nil
    end
  end
  defp expand_field(value), do: value

  defp typecast(""), do: nil
  defp typecast(value) when is_bitstring(value) do
    cond do
      Regex.match?(~r/^-?\d+(\.\d+)?$/, value) ->
        CoreTypes.cast(value, Integer) || value
      true ->
        CoreTypes.cast(value, String) || value
    end
  end
  defp typecast(value), do: value
end
