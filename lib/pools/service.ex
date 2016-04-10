defmodule Moongate.Service.Pools do
  use Moongate.Macros.ExternalResources

  @doc """
    Get the member attributes as they are defined on a pool
    module.
 """
  def get_attributes(module_name) do
    apply(pool_module(module_name), :__moongate__pool_attributes, [])
  end

  def get_deeds(module_name) do
    apply(pool_module(module_name), :__moongate__pool_deeds, [])
  end

  def pool_module(module_name) do
    [String.to_atom(String.capitalize(world_name)), Pools, module_name]
    |> Module.safe_concat
  end

  def pool_process(stage_name, module_name) do
    String.to_atom("pool_#{stage_name}__#{String.downcase(module_name)}")
  end

  def publish_to_subscriber(_member, _subscriber, _attributes) do
  end
end
