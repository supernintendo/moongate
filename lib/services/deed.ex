defmodule Moongate.Deed do
  @moduledoc """
    Provides functions related to working with deeds
    (deeds contain functions which are used to interact
    with members of rings).
  """
  use Moongate.OS

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
end
