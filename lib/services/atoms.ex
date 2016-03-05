defmodule Moongate.Atoms do
  def to_strings(value) do
    if is_atom(value) do
      parsed = Atom.to_string(value)
      parts = String.split(parsed, ".")
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
