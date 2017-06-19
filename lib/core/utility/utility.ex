defmodule Moongate.CoreUtility do
  @moduledoc """
  Provides helper functions for the Moongate
  application server.
  """

  # List of months, used by &formatted_time/0
  @months {
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  }

  @doc """
  Converts an atom into a string.

  ## Examples

  Regular atoms will be cast in the same manner
  as `Atom.to_string/1`:

      iex> Moongate.CoreUtility.atom_to_string(:zone)
      "zone"

  Module atom aliases will be returned without
  the "Elixir." prefix:

      iex> Moongate.CoreUtility.atom_to_string(Docs.PageZone)
      "Docs.PageZone"
  """
  def atom_to_string(atom) when is_atom(atom) do
    cond do
      Regex.match?(~r/^Elixir./, "#{atom}") ->
        Regex.replace(~r/^Elixir./, "#{atom}", "")
      true ->
        "#{atom}"
    end
  end

  @doc """
  Camelizes a string or an atom.

  ## Examples

      iex> Moongate.CoreUtility.camelize(:foo_bar)
      "FooBar"

      iex> Moongate.CoreUtility.camelize("lorem-ipsum")
      "LoremIpsum"
  """
  def camelize(value) do
    value
    |> Inflex.camelize
  end

  @doc """
  Checks whether or not a module exports a function
  by name.

  ## Example

      iex> Moongate.CoreUtility.exports?(Moongate.Core, "has_function?")
      true

      iex> Moongate.CoreUtility.exports?(Moongate.Core, "non_existent_function")
      false
  """
  def exports?(module, func_name) do
    :functions
    |> module.__info__
    |> Enum.any?(fn ({func, _arity}) ->
      "#{func}" == "#{func_name}"
    end)
  end

  def ls_recursive(dir \\ ".") do
    Enum.map(File.ls!(dir), fn file ->
      filename = "#{dir}/#{file}"
      cond do
        File.dir?(filename) -> ls_recursive(filename)
        true -> filename
      end
    end)
    |> List.flatten()
  end

  @doc """
  Returns a string representation of the current
  local time.

  ## Example

      iex> Moongate.CoreUtility.formatted_time
      "December 23, 2016 · 21:29"
  """
  def formatted_time do
    {{year, month, day}, {hour, min, _sec}} = :calendar.local_time()

    "#{@months |> elem(month - 1)} #{day}, #{year} · #{hour}:#{min}"
  end

  def formatted_quantity(name, quantity) do
    name =
      name
      |> Inflex.underscore
      |> String.replace("_", " ")

    case quantity do
      0 -> "no #{Inflex.pluralize(name)}"
      1 -> "1 #{Inflex.singularize(name)}"
      count -> "#{count} #{Inflex.pluralize(name)}"
    end
  end

  def formatted_quantities(map) when is_map(map) do
    map
    |> Enum.to_list()
    |> formatted_quantities()
  end
  def formatted_quantities(collection) do
    collection
    |> Enum.map_reduce(0, fn {key, quantity}, n ->
      name = atom_to_string(key)
      prefix = cond do
        n == 0 ->
          ""
        length(collection) > 1 and (n + 1) == length(collection) ->
          " and "
        true ->
          ", "
      end
      {"#{prefix}#{formatted_quantity(name, quantity)}", n + 1}
    end)
    |> elem(0)
  end

  def module_defined?(module) when is_bitstring(module) do
    {:ok, modules} = :application.get_key(:moongate, :modules)

    Enum.any?(modules, &("#{&1}" == "Elixir.#{module}"))
  end
  def module_defined?(module) when is_atom(module) do
    module
    |> atom_to_string
    |> module_defined?
  end

  def nano do
    :os.system_time(:nanosecond)
  end
end
