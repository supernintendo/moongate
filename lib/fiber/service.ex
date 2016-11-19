defmodule Moongate.Fiber.Service do
  use Moongate.Core

  def spawn_fiber({name, :npm}) do
    register(:fiber, "#{name}", {name, "cd priv/#{world_directory}/client && npm run start"})
  end
end
