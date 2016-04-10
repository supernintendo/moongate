defmodule Moongate do
  use Moongate.Macros.Processes

  def arrive!(event, stage_name) do
    event
    |> Moongate.Data.mutate({:join_stage, stage_name})
    |> Moongate.Data.mutate({:set_target_stage, stage_name})
  end

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
