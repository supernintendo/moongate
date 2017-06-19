defmodule Moongate.Core do
  @moduledoc """
  Provides core functionality for the Moongate
  application server.
  """
  alias Moongate.{
    CoreFirmware,
    CoreEvent,
    CoreETS,
    CoreNetwork,
    CoreTypes,
    CoreUtility
  }
  require Logger

  @build_salt (fn ->
    case Mix.env() do
      :test ->
        "test_seed"
      _ ->
        :crypto.hmac(
          :sha256,
          "#{:os.system_time(:nano_seconds)}",
          "#{:rand.uniform()}",
        16)
        |> Base.encode16()
        |> String.downcase()
    end
  end).()
  @game CoreFirmware.game_name()

  @doc """
  Returns a map which is used by Moongate clients to establish
  an understanding of the current Moongate instance and its
  properties. This map is often mutated by the socket process
  capturing the client connection to provide protocol and
  packet specific information.
  """
  def atlas do
    %{
      ip: CoreNetwork.local_ip(),
      rings: CoreETS.index(:ring),
      version: Moongate.version,
      zones: CoreETS.index(:zone)
    }
  end

  def dispatch(message) when is_nil(message), do: nil
  def dispatch(message) do
    :poolboy.transaction(:dispatcher, fn(pid) ->
      GenServer.cast(pid, message)
    end)
  end

  def game do
    CoreUtility.camelize(@game)
  end

  @doc """
  Passes a message string to the logger GenServer, causing
  it to be printed by the logger defined by the current
  configuration. An atom can be passed as the second
  argument for logger messages that represent a status
  change (up / down).
  """
  def log(message) do
    GenServer.cast(:logger, {:log, message})
  end
  def log(message, status) do
    GenServer.cast(:logger, {:log, message, status})
  end

  def module, do: module(Game)
  def module(name) when is_bitstring(name) or is_atom(name) do
    "#{CoreTypes.cast(game(), String)}.#{CoreTypes.cast(name, String)}"
    |> CoreUtility.module_defined?()
    |> case do
      true -> Module.safe_concat(game(), name)
      false -> nil
    end
  end

  def pid(domain) do
    process_name(domain)
    |> CoreNetwork.pid_for_name()
  end

  def process_name({zone, nil}, %{} = params), do: process_name(zone, params)
  def process_name({{zone, zone_id}, {ring, _rule}}, %{} = params) do
    process_name({{zone, zone_id}, ring}, params)
  end
  def process_name({{zone, zone_id}, ring}, %{} = params) do
    zone = CoreTypes.cast({zone, String})
    ring = CoreTypes.cast({ring, String})

    Enum.reduce(params, "#{ring}@#{zone}_#{zone_id}", fn param, acc ->
      case param do
        {:prefix, true} -> "ring_#{acc}"
        _ -> acc
      end
    end)
  end
  def process_name({zone, ring}, params) when is_atom(ring) do
    process_name({{zone, "$"}, ring}, params)
  end
  def process_name({zone, zone_id}, params) do
    zone = CoreTypes.cast({zone, String})

    Enum.reduce(params, "#{zone}_#{zone_id}", fn param, acc ->
      case param do
        {:prefix, true} -> "zone_#{acc}"
        _ -> acc
      end
    end)
  end
  def process_name(zone, params), do: process_name({zone, "$"}, params)
  def process_name(domain), do: process_name(domain, %{prefix: true})

  def trigger(%CoreEvent{} = event, handler_name) do
    case event do
      %{rule: rule} when not is_nil(rule) ->
        trigger(event, module(rule), handler_name)
      %{ring: ring} when not is_nil(ring) ->
        trigger(event, module(ring), handler_name)
      %{zone: {zone, _zone_id}} when not is_nil(zone) ->
        trigger(event, module(zone), handler_name)
      %{zone: zone} when not is_nil(zone) ->
        trigger(event, module(zone), handler_name)
      _ ->
        trigger(event, module(Game), handler_name)
    end
  end

  def trigger(%CoreEvent{}, handler_module, _handler_name)
      when is_nil(handler_module), do: nil
  def trigger(%CoreEvent{} = event, handler_module, handler_name) do
    cond do
      !CoreUtility.exports?(handler_module, event_func(handler_name)) ->
        log({:warning, "#{CoreUtility.atom_to_string(handler_module)}: '#{handler_name}' event ignored: no handler"})
        nil
      true ->
        apply(handler_module, event_func(handler_name, :atom), [event])
    end
  end

  def uuid(key) do
    Hashids.new([salt: @build_salt, min_len: 2])
    |> Hashids.encode(CoreETS.increment(key))
  end

  def zones, do: Moongate.Zone.index()

  defp event_func(event_name), do: "handle_#{event_name}_event"
  defp event_func(event_name, :atom) do
    event_func(event_name)
    |> String.to_existing_atom()
  end
end
