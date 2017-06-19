defmodule Moongate.DSL.Terms.Buffer do
  alias Moongate.{
    CoreEvent,
    CoreTime,
    DSL.Queue
  }

  defmodule Dispatcher do
    def call({Buffer, duration}, %CoreEvent{} = event) do
      case CoreTime.convert(duration, :millisecond) do
        nil ->
          Map.put(event, :void, true)
        interval ->
          updated_event = Map.put(event, :queue, tl(event.queue))
          Process.send_after(:support, {:"$gen_cast", {:dispatch, updated_event}}, round(interval))

          Map.put(event, :void, true)
      end
    end
  end

  def buffer(%CoreEvent{} = event, {interval, unit})
  when is_number(interval)
  when is_atom(unit) do
    {Buffer, {interval, unit}}
    |> Queue.push(event)
  end
end
