defmodule Moongate do
  @moduledoc """
    Provides macros for the World module of a
    Moongate world (the World module is the
    entry point of the world).
  """
  use Moongate.Macros.Mutations
  use Moongate.Macros.Processes

  @doc """
    Causes the origin of a client event to join
    a stage.
  """
  def arrive(event, stage_name) do
    event
    |> mutate({:join_stage, stage_name})
    |> mutate({:set_target_stage, stage_name})
  end

  @doc """
    Defines the list of stages within a world.
    Each module name in this map will be passed
    to a new stage process when Moongate starts.
  """
  defmacro stages(stage_map) do
    quote do
      def __moongate_stages(_), do: __moongate_stages
      def __moongate_stages do
        unquote(stage_map)
      end
    end
  end
end
