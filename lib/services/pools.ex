defmodule Moongate.Service.Pools do
  use Moongate.Macros.ExternalResources

  @doc """
    Get the member attributes as they are defined on a pool
    module.
 """
  def get_attributes(module_name) do
    attributes = apply(pool_module(module_name), :__moongate__pool_attributes, [])
    attributes
  end

  def get_deeds(module_name) do
    deeds = apply(pool_module(module_name), :__moongate__pool_deeds, [])
    deeds
  end

  def pool_module(module_name) do
    world = String.to_atom(String.capitalize(world_name))
    Module.safe_concat([world, Pools, module_name])
  end

  def pool_process(stage_name, module_name) do
    String.to_atom("pool_#{stage_name}__#{String.downcase(module_name)}")
  end

  def publish_to_subscriber(member, subscriber, attributes) do
  end
end
