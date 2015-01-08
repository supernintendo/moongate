defmodule Mixins.SocketWriter do
  defmacro __using__(opts) do
    quote do
      # Send a message to a socket connection.
      defp write_to(socket, message) do
        parsed_message = "cast=#{Atom.to_string(message[:cast])}, namespace=#{Atom.to_string(message[:namespace])}, value=#{message[:value]}"
        socket |> Socket.Stream.send!(parsed_message)
      end
    end
  end
end
