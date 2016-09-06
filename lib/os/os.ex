defmodule Moongate.OS do
  defmacro __using__(_) do
    quote do
      use Moongate.OS.Logging
      use Moongate.OS.Resources
      use Moongate.OS.Processes
      use Moongate.OS.Worlds
      import Moongate.OS.Sockets
    end
  end
end
