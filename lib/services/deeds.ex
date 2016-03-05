defmodule Moongate.Service.Deeds do
  use Moongate.Macros.ExternalResources

  def has_function?(deed_module, func_name) do
    functions = deed_module.__info__(:functions)

    Enum.any?(functions, fn ({func, arity}) ->
      "#{func}" == func_name
    end)
  end

  def deed_module(module_name) do
    world = String.to_atom(String.capitalize(world_name))
    Module.safe_concat([world, Deeds, module_name])
  end

  def get_functions(module_name) do
    apply(deed_module(module_name), :__info__, [:functions])
  end
end
