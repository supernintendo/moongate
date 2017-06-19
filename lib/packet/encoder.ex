defmodule Moongate.PacketEncoder do
  alias Moongate.{
    CoreTime,
    CoreTypes,
    NativeModules
  }

  @packet Application.get_env(:moongate, :packet)
  @delimiter "|"

  @doc """
  Constructs a packet from values within a map or
  %Moongate.CorePacket{}.
  """
  def encode(packet) do
    case encode_packet(packet) do
      {:ok, packet} -> packet
      _ -> nil
    end
  end

  def encode_member(%{} = member, %{} = schema) do
    "#{encode_schema_keys(schema)}:#{encode_member_values(member, schema)}"
  end
  def encode_members(members, %{} = schema) do
    "#{encode_schema_keys(schema)}:#{encode_members_values(members, schema)}"
  end
  def encode_member(%{} = member, %{} = schema, :suppress_schema) do
    "#{encode_member_values(member, schema)}"
  end
  def encode_members(members, %{} = schema, :suppress_schema) do
    "#{encode_members_values(members, schema)}"
  end

  def encode_schema_keys(%{} = schema) do
    Map.keys(schema)
    |> Enum.sort()
    |> Enum.map(&(@packet.compressor.compress(&1)))
    |> Enum.join(@delimiter)
  end

  def encode_member_values(%{} = member, %{} = schema) do
    member
    |> Map.take(Map.keys(schema))
    |> Enum.sort_by(fn {key, _value} -> key end)
    |> Enum.map(fn {key, value} ->
      case schema[key] do
        String -> encode_body("#{value}")
        _type -> value
      end
    end)
    |> Enum.join(@delimiter)
  end

  def encode_members_values(members, schema) do
    members
    |> Enum.map(&(encode_member_values(&1, schema)))
    |> Enum.join("&")
  end

  def encode_tween(%Exmorph.Tween{} = tween) do
    started_at_ms =
      {tween.started_at, :nanosecond}
      |> CoreTime.convert(:millisecond)
      |> round()
    every_ms =
      {tween.every, :nanosecond}
      |> CoreTime.convert(:millisecond)
      |> round()
    delta = CoreTypes.cast({tween.add, Integer})

    "~#{started_at_ms}d#{delta}~#{every_ms}"
  end

  def encode_body(value, :json), do: Poison.encode!(value)
  def encode_body(value), do: String.replace("#{value}", @delimiter, "\\#{@delimiter}")

  def encode_pair(key, value), do: "#{key}:#{encode_body(value)}"
  def encode_pair(key, value, :json), do: "#{key}:#{encode_body(value, :json)}"

  def delimit(strings) when is_list(strings) do
    strings
    |> Enum.map(&compress/1)
    |> Enum.join(@delimiter)
  end

  def join(strings) when is_list(strings) do
    Enum.join(strings, "&")
  end

  defp compress(value) when is_number(value), do: value
  defp compress(value) do
    @packet.compressor.compress(value) || value
  end

  defp encode_packet(%{zone: nil} = packet) do
    encode_packet(%{packet | zone: {nil, nil}})
  end
  defp encode_packet(%{zone: {zone, zone_id}} = packet) do
    NativeModules.Packets.encode(
      CoreTypes.cast(packet.body, String),
      CoreTypes.cast(compress(packet.handler), String),
      CoreTypes.cast(compress(packet.ring), String),
      CoreTypes.cast(compress(packet.rule), String),
      CoreTypes.cast(compress(zone), String),
      CoreTypes.cast(zone_id, String))
  end
  defp encode_packet(%{zone: zone} = packet) do
    encode_packet(%{packet | zone: {zone, "$"}})
  end
end
