defmodule Moongate.Worlds do
  use Moongate.Macros.Worlds

  def get_world do
    if Mix.env() == :test do
      "test"
    else
      Application.get_env(:moongate, :world) || "default"
    end
  end

  def world_apply(args, func) do
    cond do
      is_list(args) -> apply(world_module, func, args)
      true -> world_apply([args], func)
    end
  end
end
