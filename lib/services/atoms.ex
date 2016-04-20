defmodule Moongate.Atoms do
  @moduledoc """
    Provides functions related to working with atoms.
  """

  @doc """
    Takes an atom, specifically one for a module
    name, and returns a string representation of the
    module name. "Elixir" is removed from the
    beginning of the module name to facilitate
    aliased module references within the Moongate
    DSL.
  """
  def to_strings(value) do
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
end
