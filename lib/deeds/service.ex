defmodule Moongate.Deed.Service do
  @moduledoc """
    Provides functions related to working with deeds
    (deeds contain functions which are used to interact
    with members of pools).
  """
  use Moongate.Macros.ExternalResources

  @doc """
    Return the actual module name for a deed when only
    given its first part.
  """
  def deed_module(module_name) do
    [:"#{String.capitalize(world_name)}", Deeds, module_name]
    |> Module.safe_concat
  end
end
