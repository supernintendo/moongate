defmodule Moongate.Pool.Mutations do
  import Moongate.Macros.SocketWriter
  use Moongate.Macros.Processes

  def mutation({:transform, :lin, key, tag, value}, _event, member) do
    {current, transformations} = member[key]

    {key, {current, [{:lin, tag, value, Moongate.Time.current_ms}]}}
  end
end
