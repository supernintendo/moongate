defmodule Moongate.Modules do
  @doc """
    Check if a function is defined on the module
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
  def to_string(module) do
    "#{module}"
    |> String.replace("Elixir.", "")
  end
end
