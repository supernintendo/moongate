defmodule Moongate.Pool.Mutations do
  def mutation({:transform, :lin, key, tag, value}, _event, member) do
    {current, _transformations} = member[key]

    {key, {current, [{:lin, tag, value, Moongate.Time.current_ms}]}}
  end

  def mutation({:set, key, value}, _event, member) do
    {_current, transformations} = member[key]

    {key, {value, transformations}}
  end
end
