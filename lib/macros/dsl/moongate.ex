defmodule Moongate do
  alias Moongate.Service.Stages, as: Stages
  use Moongate.Macros.Processes

  def arrive(event, stage_name), do: Stages.arrive(event, stage_name)
  def depart(event), do: Stages.depart(event)

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
end
