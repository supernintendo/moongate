defmodule Macros.SocketWriter do
  defmacro __using__(_) do
    {:ok, read} = File.read "config/config.json"
    {:ok, config} = JSON.decode(read)
    world = config["world"] || "default"
    {:ok, read} = File.read "worlds/#{world}/server.json"
    {:ok, server_config} = JSON.decode(read)

    quote do
      # Send a message to a socket connection.
      defp write_to(target, message) do
        delimiter = unquote(server_config["outgoing_packet_delimiter"] || ",")
        parsed_message = "begin=true#{delimiter} cast=#{Atom.to_string(message[:cast])}#{delimiter} namespace=#{Atom.to_string(message[:namespace])}#{delimiter} value=#{message[:value]}#{delimiter} end=true#{delimiter} "

        case target.protocol do
          :tcp -> target.port |> Socket.Stream.send! parsed_message
          :udp -> target.port |> Socket.Datagram.send! parsed_message, {target.ip, String.to_integer(target.id)}
        end
      end
    end
  end
end
