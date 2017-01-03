defmodule Moongate.ZoneService do
  def arrive(%Moongate.CoreOrigin{} = target, zone_module, name) do
    process_name = Moongate.ZoneService.process_name(zone_module, name)

    Moongate.CoreNetwork.call({:arrive, target}, process_name)
  end
  def arrive(_origin, _zone_module, _name), do: nil

  def depart(event) do
    Moongate.CoreNetwork.cast({:depart, event}, event.to)
  end

  def process_name(zone_module, id) do
    "zone_#{Moongate.Core.atom_to_string(zone_module)}_#{id}"
  end

  def zone_module(module_name) do
    [
      Moongate.Core.world_name
      |> String.capitalize
      |> String.replace("-", "_")
      |> Moongate.Core.camelize
      |> String.to_atom, Zone, module_name
    ]
    |> Module.safe_concat
  end
end
