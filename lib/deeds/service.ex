defmodule Moongate.Deed.Service do
  use Moongate.Macros.ExternalResources

  def has_function?(deed_module, func_name) do
    :functions
    |> deed_module.__info__
    |> Enum.any?(fn ({func, _arity}) ->
      "#{func}" == func_name
    end)
  end

  def deed_module(module_name) do
    [:"#{String.capitalize(world_name)}", Deeds, module_name]
    |> Module.safe_concat
  end

  def get_functions(module_name) do
    apply(deed_module(module_name), :__info__, [:functions])
  end
end
