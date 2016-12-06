defmodule Moongate.Fiber.Service do
  @commands %{
    npm: "client && npm run start"
  }
  @root "priv/#{Moongate.Core.world_directory}/"

  def spawn_fiber({name, command}) do
    Moongate.Network.register(
      :fiber,
      "#{name}",
      {name, "cd #{@root} && #{@commands[command]}"}
    )
  end
end
