defmodule Moongate.Ring.Mutations do
  def mutate({:transform, :lin, key, tag, value}, _event, member) do
    {current, _transformations} = member[key]

    {key, {current, [{:lin, tag, value, :erlang.system_time()}]}}
  end

  def mutate({:set, key, value}, _event, member) do
    {_current, transformations} = member[key]

    {key, {value, transformations}}
  end
end
