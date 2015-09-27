defmodule Moongate.Macros.SocketWriter do
  def write_to(target, tag, message) do
    auth_token = target.auth.identity
    name = Atom.to_string(Process.info(self())[:registered_name])
    tag = Atom.to_string(tag)
    packet_length = String.length(auth_token <> name <> tag <> message)
    parsed_message = "#{packet_length}{#{auth_token} #{name} #{tag} #{message}}"

    case target.protocol do
      :tcp -> target.port |> Socket.Stream.send! parsed_message
              :udp -> target.port |> Socket.Datagram.send! parsed_message, {target.ip, String.to_integer(target.id)}
                      :web -> target.port |> Socket.Web.send!({:text, parsed_message})
    end
  end
end
