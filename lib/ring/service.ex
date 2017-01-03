defmodule Moongate.RingService do
  def get_attributes(module_name) do
    apply(ring_module(module_name), :__ring_attributes, [])
  end

  def get_deeds(module_name) do
    apply(ring_module(module_name), :__ring_deeds, [])
  end

  def encode(member, schema) do
    member
    |> Enum.map(fn({key, value}) ->
      case schema[key] do
        :origin -> {key, value.id}
        _type -> {key, value}
      end
    end)
    |> Enum.into(%{})
    |> Poison.encode!
  end

  def member_attr(member, key) do
    mutations = elem(member[key], 1)

    if length(mutations) > 0 do
      mod = Enum.reduce(mutations, 0, fn({_type, _tag, amount, time_started}, acc) ->
        acc + amount * (:erlang.system_time() - time_started)
      end)
      elem(member[key], 0) + mod
    else
      elem(member[key], 0)
    end
  end

  def member_defaults(schema) do
    schema
    |> Enum.map(fn(attribute) ->
      case attribute do
        {key, :float} -> {key, 0.0}
        {key, :integer} -> {key, 0}
        {key, :string} -> {key, ""}
        {key, _type} -> {key, nil}
      end
    end)
    |> Enum.into(%{})
  end

  def member_params(params, schema) do
    params
    |> Enum.map(fn({key, value}) ->
      case schema[key] do
        :float -> {key, member_value({:float, value})}
        :integer -> {key, member_value({:integer, value})}
        _ -> {key, value}
      end
    end)
    |> Enum.into(%{})
  end

  def member_value({:float, value}) when is_float(value), do: value
  def member_value({:float, value}) when is_integer(value), do: (value / 1)
  def member_value({:float, value}) do
    case Float.parse(value) do
      {result, _remain} -> result |> IO.inspect
      _ -> nil
    end
  end

  def member_value({:integer, value}) when is_integer(value), do: value
  def member_value({:integer, value}) when is_float(value), do: round(value)
  def member_value({:integer, value}) do
    case Integer.parse(value) do
      {result, _remain} -> result
      _ -> nil
    end
  end

  def member_value({_type, value}) do
    value
  end

  def member_to_string(member) do
    member
    |> Enum.map(fn({key, _value}) -> {key, member_attr(member, key)} end)
    |> Enum.map(fn({key, value}) ->
      case value do
        %Moongate.CoreOrigin{} -> {key, value.id}
        _ -> {key, value}
      end
    end)
    |> Enum.map(fn({_key, value}) -> "#{value}" end)
    |> Enum.join(",")
  end

  def process_name({zone_process_name, zone_process_id, module_name}) do
    "#{Moongate.Core.atom_to_string(module_name)}@#{zone_process_name}_#{zone_process_id}"
  end

  def ring_module(module_name) do
    [
      Moongate.Core.world_name
      |> String.capitalize
      |> String.replace("-", "_")
      |> Moongate.Core.camelize
      |> String.to_atom, Ring, module_name
    ]
    |> Module.safe_concat
  end

  def schema do
    IO.inspect Moongate.Core.world_module
  end

  def subscribe_to_ring(%Moongate.CoreOrigin{} = origin, {ring, name, id}) do
    process = process_name({name, id, Moongate.Core.atom_to_string(ring)})

    Moongate.CoreNetwork.cast({:subscribe, origin}, "ring", process)
  end

  def to_string_list(rings) do
    rings
    |> Enum.map(&(String.split(&1, "@")))
    |> Enum.map(&(&1 |> hd))
    |> Enum.join(" ")
  end
end
