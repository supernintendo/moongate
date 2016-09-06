defmodule Moongate.Fiber.Service do
  use Moongate.OS

  def spawn_fiber({name, :npm}) do
    register(:fiber, "#{name}", {name, "cd priv/#{world_directory}/client && npm run start"})
  end
end
