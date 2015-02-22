defmodule Mixins.SocketWriter do
  defmacro __using__(_) do
    quote do
      # Send a message to a socket connection.
      defp write_to(target, message) do
        parsed_message = "begin=true, cast=#{Atom.to_string(message[:cast])}, namespace=#{Atom.to_string(message[:namespace])}, value=#{message[:value]}, end=true, "
        target.port |> Socket.Stream.send!(parsed_message)
      end
    end
  end
end
