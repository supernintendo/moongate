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

  def enroll(transaction, stage_name) do
    tell_async(:stage, stage_name, {:enroll, transaction.origin})
  end

  def kick(transaction) do
    tell_async(:stage, transaction.from, {:kick, transaction.origin})
  end
end