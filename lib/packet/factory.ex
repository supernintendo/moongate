defmodule Moongate.PacketFactory do
  alias Moongate.CorePacket

  @packet Application.get_env(:moongate, :packet)

  def echo(body) do
    %CorePacket{
      body: @packet.encoder.encode_body(body),
      handler: :echo
    }
  end

  def command(command_name, args) do
    %CorePacket{
      body: @packet.encoder.encode_pair(command_name, args, :json),
      handler: :command
    }
  end

  def ping do
    %CorePacket{
      body: :os.system_time(:milli_seconds),
      handler: :ping
    }
  end

  def attach(key, value) when is_list(value), do: attach(key, value, :json)
  def attach(key, value) when is_map(value), do: attach(key, value, :json)
  def attach(key, value) do
    %CorePacket{
      body: @packet.encoder.encode_pair(key, value),
      handler: :attach
    }
  end
  def attach(key, value, :json) do
    %CorePacket{
      body: @packet.encoder.escape_pair(key, value, :json),
      handler: :attach
    }
  end

  def join({zone, zone_name}) do
    %CorePacket{
      handler: :join,
      zone: {zone, zone_name}
    }
  end

  def leave({zone, zone_name}) do
    %CorePacket{
      handler: :leave,
      zone: {zone, zone_name}
    }
  end

  def index_members(scope, {members, %{} = schema}) do
    members
    |> @packet.compressor.buffer()
    |> Enum.map(fn chunk ->
      %CorePacket{}
      |> scope_packet(scope)
      |> struct(%{
        body: @packet.encoder.encode_members(chunk, schema, :suppress_schema),
        handler: :index_members
      })
    end)
  end

  def show_members(scope, {members, %{} = schema}) do
    members
    |> @packet.compressor.buffer()
    |> Enum.map(fn chunk ->
      %CorePacket{}
      |> scope_packet(scope)
      |> struct(%{
        body: @packet.encoder.encode_members(chunk, schema),
        handler: :show_members
      })
    end)
  end

  def show_morphs(scope, morphs) do
    morphs
    |> represent_morphs()
    |> @packet.compressor.buffer()
    |> Enum.map(fn chunk ->
      %CorePacket{}
      |> scope_packet(scope)
      |> struct(%{
        body: @packet.encoder.join(chunk),
        handler: :show_morphs
      })
    end)
  end

  def drop_members(scope, m_indices) do
    %CorePacket{}
    |> scope_packet(scope)
    |> struct(%{
      body: Enum.join(m_indices, ","),
      handler: :drop_members
    })
  end

  defp scope_packet(packet, {zone, zone_id, ring}) do
    struct(packet, %{
      ring: ring,
      zone: {zone, zone_id}
    })
  end
  defp scope_packet(packet, _scope), do: packet

  defp represent_morphs(morphs) do
    morphs
    |> Enum.flat_map(fn {rule, attributes} ->
      attributes
      |> Enum.flat_map(fn {key, tweens} ->
        Enum.map(tweens, fn {index, tween} ->
          [rule, key, index]
          |> @packet.encoder.delimit()
          |> @packet.encoder.encode_pair(@packet.encoder.encode_tween(tween))
        end)
      end)
    end)
  end
end
