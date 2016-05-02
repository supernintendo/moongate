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
end
