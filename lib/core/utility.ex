defmodule Moongate.Utility do
  @doc """
    Takes an atom, specifically one for a module
    name, and returns a string representation of the
    module name. "Elixir" is removed from the
    beginning of the module name to facilitate
    aliased module references within the Moongate
    DSL.
  """
  use Moongate.Core

  def atoms_to_strings(value) do
    if is_atom(value) do
      parts = value
      |> Atom.to_string
      |> String.split(".")

      if (hd(parts) == "Elixir") do
        Enum.join(tl(parts), ".")
      else
        Enum.join(parts, ".")
      end
    else
      value
    end
  end

  @doc """
    Return the actual module name for a deed when only
    given its first part.
  """
  def deed_module(module_name) do
    [world_name
     |> String.capitalize
     |> String.replace("-", "_")
     |> Mix.Utils.camelize
     |> String.to_atom, Deed, module_name]
    |> Module.safe_concat
  end

  def formatted_time do
    {{year, month, day}, {hour, min, _sec}} = :calendar.local_time()

    "#{@months |> elem(month - 1)} #{day}, #{year} · #{hour}:#{min} "
  end

  @doc """
    Return the name of the world. This name is used
    as the name of the world's directory within
    `priv/worlds`.
  """
  def get_world do
    if Mix.env() == :test do
      "test"
    else
      Application.get_env(:moongate, :world) || "default"
    end
  end

  def local_ip do
    {:ok, parts} = :inet.getif
    parts
    |> hd
    |> elem(0)
    |> Tuple.to_list
    |> Enum.join(".")
  end

  @doc """
    Check if a function is defined on a module
  """
  def has_function?(module, func_name) do
    :functions
    |> module.__info__
    |> Enum.any?(fn ({func, _arity}) ->
      "#{func}" == func_name
    end)
  end

  @doc """
    Converts a naked (no preceding namespaces) module
    atom to a string.
  """
  def module_to_string(module) do
    "#{module}"
    |> String.replace("Elixir.", "")
  end

  @doc """
    Call a function within the `World` module of the
    current world.
    """
  def world_apply(func) do
    apply(world_module, func, [])
  end
  def world_apply(args, func) do
    cond do
      is_list(args) -> apply(world_module, func, args)
      true -> world_apply([args], func)
    end
  end
end
