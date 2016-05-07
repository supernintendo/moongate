defmodule Moongate.Worlds do
  @moduledoc """
    Provides functions related to working with worlds
    (worlds are user-made projects that run on the
    Moongate platform).
  """
  use Moongate.Macros.Worlds

  @doc """
    Return the name of the world. This name is used
    as the name of the world's directory within
    `priv/worlds`.
  """
  def get_world do
    Application.get_env(:moongate, :world) || "default"
  end

  @doc """
    Call a function within the `World` module of the
    current world.
  """
  def world_apply(args, func) do
    cond do
      is_list(args) -> apply(world_module, func, args)
      true -> world_apply([args], func)
    end
  end
end
