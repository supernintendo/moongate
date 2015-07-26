defmodule Macros.SocketWriter do
  defmacro __using__(_) do
    quote do
      # Send a message to a socket connection.
      defp write_to(target, message) do
        parsed_message = "begin=true, cast=#{Atom.to_string(message[:cast])}, namespace=#{Atom.to_string(message[:namespace])}, value=#{message[:value]}, end=true, "

        case target.protocol do
          :tcp -> target.port |> Socket.Stream.send! parsed_message
          :udp -> target.port |> Socket.Datagram.send! parsed_message, {target.ip, target.id}
        end
      end
    end
  end
end
