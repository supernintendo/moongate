defmodule Moongate.CoreTypes do
  defmodule Options do
    defstruct raise_on_error: false
  end
  alias Moongate.CoreUtility

  def cast(value, type), do: cast({value, type})
  def cast(value, type, cast_params) do
    cast({value, type, cast_params})
  end
  def cast(input) when is_tuple(input), do: typecast(input, %Options{})

  def cast!(value, type), do: cast!({value, type})
  def cast!(value, type, cast_params) do
    cast!({value, type, cast_params})
  end
  def cast!(input) when is_tuple(input) do
    typecast(input, %Options{ raise_on_error: true })
  end

  defp typecast({value, Boolean}, _opts) when is_boolean(value), do: value
  defp typecast({1, Boolean}, _opts), do: true
  defp typecast({1.0, Boolean}, _opts), do: true
  defp typecast({"t", Boolean}, _opts), do: true
  defp typecast({"true", Boolean}, _opts), do: true
  defp typecast({0, Boolean}, _opts), do: false
  defp typecast({0.0, Boolean}, _opts), do: false
  defp typecast({"f", Boolean}, _opts), do: false
  defp typecast({"false", Boolean}, _opts), do: false
  defp typecast({value, Boolean}, %Options{} = opts) do
    no_typecast_def("Cannot cast #{inspect value} to boolean", opts)
  end

  defp typecast({value, Integer}, _opts) when is_integer(value), do: value
  defp typecast({value, Integer}, _opts) when is_float(value), do: round(value)
  defp typecast({value, Integer}, %Options{} = opts)
  when is_bitstring(value) do
    case Integer.parse(value) do
      {cast_value, _rem} -> cast_value
      :error -> no_typecast_def("Cannot cast #{value} to integer", opts)
    end
  end
  defp typecast({true, Integer}, _opts), do: 1
  defp typecast({false, Integer}, _opts), do: 0
  defp typecast({true, Integer, _round}, _opts), do: 1
  defp typecast({false, Integer, _round}, _opts), do: 0
  defp typecast({value, Integer, :round_down}, _opts) when is_float(value) do
    value
    |> Float.floor()
    |> round()
  end
  defp typecast({value, Integer, :round_up}, _opts) when is_float(value) do
    value
    |> Float.ceil()
    |> round()
  end
  defp typecast({value, Integer}, %Options{} = opts) do
    no_typecast_def("Cannot cast #{inspect value} to integer", opts)
  end
  defp typecast({value, Integer, _round}, %Options{} = opts) do
    no_typecast_def("Cannot cast #{inspect value} to integer", opts)
  end

  defp typecast({value, Float}, _opts) when is_float(value), do: value
  defp typecast({value, Float}, _opts) when is_integer(value), do: value * 1.0
  defp typecast({value, Float}, %Options{} = opts) when is_bitstring(value) do
    case Float.parse(value) do
      {cast_value, _rem} -> cast_value
      _ -> no_typecast_def("Cannot cast #{value} to integer", opts)
    end
  end
  defp typecast({true, Float}, _opts), do: 1.0
  defp typecast({false, Float}, _opts), do: 0.0
  defp typecast({value, Float}, %Options{} = opts) do
    no_typecast_def("Cannot cast #{inspect value} to float", opts)
  end

  defp typecast({value, String}, _opts) when is_bitstring(value), do: value
  defp typecast({value, String}, _opts) when is_integer(value), do: "#{value}"
  defp typecast({value, String}, _opts) when is_float(value), do: "#{value}"
  defp typecast({value, String}, _opts) when is_atom(value) do
    CoreUtility.atom_to_string(value)
  end
  defp typecast({value, String}, _opts) when is_nil(value), do: ""
  defp typecast({value, String}, _opts), do: "#{inspect value}"

  defp typecast({value, Atom}, _opts) when is_atom(value), do: cast({"#{value}", Atom})
  defp typecast({value, Atom}, _opts) when is_bitstring(value), do: String.to_existing_atom(value)
  defp typecast({value, Atom, whitelist}, %Options{} = opts) when is_atom(value) do
    case Enum.find(whitelist, &(&1 == value)) do
      nil -> no_typecast_def("#{value} not found within whitelist: #{inspect whitelist}", opts)
      result -> result
    end
  end
  defp typecast({value, Atom, whitelist}, %Options{} = opts)
  when is_bitstring(value) when is_list(whitelist) do
    cond do
      !Enum.all?(whitelist, &(is_atom(&1))) ->
        no_typecast_def("All values within whitelist must be atoms.", opts)
      !Enum.find(whitelist, &(value == cast({&1, String}))) ->
        no_typecast_def("#{value} not found within whitelist: #{inspect whitelist}", opts)
      true ->
        cast({value, Atom})
    end
  end
  defp typecast({value, Atom}, %Options{} = opts) do
    no_typecast_def("Cannot cast #{inspect value} to atom", opts)
  end
  defp typecast({%{} = map, %{__struct__: struct_module} = struct}, %Options{} = opts) do
    cond do
      !CoreUtility.exports?(struct_module, :types) ->
        no_typecast_def("%#{inspect struct_module}{} cannot be cast to; #{inspect struct_module}.types/0 does not return map", opts)
      true ->
        Map.keys(struct)
        |> Enum.map(&(typecast_field(&1, map, struct, struct_module.types(), opts)))
        |> Enum.filter(&(&1))
        |> Enum.into(%{})
        |> Map.put(:__struct__, struct_module)
    end
  end

  defp typecast({value, type}, %Options{} = opts) do
    no_typecast_def("Cannot cast #{inspect value} to #{type}", opts)
  end
  defp typecast({value, type, cast_params}, %Options{} = opts) do
    no_typecast_def("Cannot cast #{inspect value} to #{type} with params #{cast_params}", opts)
  end

  defp typecast_field(key, %{} = map, %{} = target, %{} = schema, %Options{} = opts) do
    cond do
      !schema[key] ->
        {key, Map.get(map, key)}
      !is_atom(schema[key]) && !is_tuple(schema[key]) ->
        no_typecast_def("#{key} for schema #{inspect schema} must be an atom or tuple", opts)
      value = Map.get(map, key) || Map.get(map, typecast({key, String}, opts)) ->
        case is_tuple(schema[key]) do
          true -> {key, typecast(Tuple.insert_at(schema[key], 0, value), opts)}
          false -> {key, typecast({value, schema[key]}, opts)}
        end
      true ->
        {key, Map.get(target, key)}
    end
  end

  defp no_typecast_def(error, %Options{ raise_on_error: true}), do: raise error
  defp no_typecast_def(_error, _options), do: nil
end
