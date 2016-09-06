defmodule Moongate.OS.Logging do
  defmacro __using__(_) do
    quote do
      defp log(status, message) do
        GenServer.cast(:logger, {:log, status, message})
      end
    end
  end
end
