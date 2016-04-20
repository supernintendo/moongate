defmodule Moongate.Deed.Service do
  @moduledoc """
    Provides functions related to working with deeds
    (deeds contain functions which are used to interact
    with members of pools).
  """
  use Moongate.Macros.ExternalResources

  @doc """
    Check if a function is defined on the deed's
    module.
  """
  def has_function?(deed_module, func_name) do
    :functions
    |> deed_module.__info__
    |> Enum.any?(fn ({func, _arity}) ->
      "#{func}" == func_name
    end)
  end

  @doc """
    Return the actual module name for a deed when only
    given its first part.
  """
  def deed_module(module_name) do
    [:"#{String.capitalize(world_name)}", Deeds, module_name]
    |> Module.safe_concat
  end
end
