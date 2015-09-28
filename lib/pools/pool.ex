defmodule Moongate.PoolState do
  defstruct attributes: %{}, members: [], name: nil, spec: nil, triggers: []
end

defmodule Moongate.Pools.Pool do
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.ExternalResources
  use Moongate.Macros.Processes

  def start_link({name, pool}) do
    attributes = get_attributes(pool)
    triggers = get_triggers(pool)
    state = %Moongate.PoolState{
      attributes: attributes,
      name: name,
      triggers: triggers,
      spec: pool
    }
    link(state, "pool", name)
  end

  def handle_cast({:init}, state) do
    Enum.map(state.triggers, &(initialize_trigger(&1, state)))
    {:noreply, state}
  end

  def handle_cast({:add_to_pool, params}, state) do
    attributes = Enum.map(state.attributes, &(initial_attributes_for_member(&1, params)))
    state = %{state | members: state.members ++ [attributes]}
    {:noreply, state}
  end

  def handle_cast({:describe, origin}, state) do
    attributes = Enum.map(state.attributes, fn(attribute) ->
      case attribute do
        {key, {type, value}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type) <> " "
        {key, {type}} -> Atom.to_string(key) <> ":" <> Atom.to_string(type) <> " "
      end
    end)
    write_to(origin, :describe, List.to_string(attributes))
    {:noreply, state}
  end

  defp get_attributes(module_name) do
    world = String.to_atom(String.capitalize(world_name))
    pool_module = Module.safe_concat([world, Pools, module_name])
    attributes = apply(pool_module, :__moongate__pool_attributes, [])
    attributes
  end

  defp get_triggers(module_name) do
    world = String.to_atom(String.capitalize(world_name))
    pool_module = Module.safe_concat([world, Pools, module_name])
    triggers = apply(pool_module, :__moongate__pool_triggers, [])
    triggers
  end

  defp initial_attributes_for_member({key, {type}}, params) do
    initial_attributes_for_member({key, {type, default_value_for_type(type)}}, params)
  end

  defp initial_attributes_for_member({key, {type, initial_value}}, params) do
    {key, {params[key] || initial_value, []}}
  end

  defp initialize_trigger({trigger, condition}, state) do
    case condition do
      {:every, time} -> Process.send_after(self(), {:trigger, trigger, condition}, time)
      _ -> nil
    end
  end

  defp default_value_for_type(type) do
    case type do
      :int -> 0
      :string -> ""
      :origin -> %Moongate.SocketOrigin{}
    end
  end

  def handle_info({:trigger, callback, {:every, time}}, state) do
    Enum.map(state.members, &(pool_callback(callback, &1, state)))
    Process.send_after(self(), {:trigger, callback, {:every, time}}, time)
    {:noreply, state}
  end

  def pool_callback(callback, member, state) do
    world = String.to_atom(String.capitalize(world_name))
    pool_module = Module.safe_concat([world, Pools, state.spec])
    pools = Map.put(%{}, state.spec, state.members)
    e = %{
      this: member,
      pools: pools
    }   
    apply(pool_module, callback, [e])
  end
end
