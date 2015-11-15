defmodule Moongate do
  use Moongate.Macros.Processes

  defmacro stages(stage_map) do
    quote do
      def __moongate_stages(_), do: __moongate_stages
      def __moongate_stages do
        unquote(stage_map)
      end
    end
  end

  defmacro you_start_on(stage_name) do
    quote do
      def ___moongate_initial_stage do
        unquote(stage_name)
      end
    end
  end

  def depart(event) do
    tell_async(:stage, event.from, {:depart, event.origin})
  end

  def arrive(event, stage_name) do
    tell_async(:stage, stage_name, {:arrive, event.origin})
  end
end
