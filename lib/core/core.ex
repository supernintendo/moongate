defmodule Moongate.Core do
  defmacro __using__(_) do
    quote do
      use Moongate.Core.Logging
      use Moongate.Core.Resources
      use Moongate.Core.Processes
      use Moongate.Core.Worlds
      import Moongate.Core.Sockets
    end
  end
end
