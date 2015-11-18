defmodule Moongate.Macros.SocketWriter do
  def write_to(target, tag, message) do
    write_to(target, tag, Atom.to_string(Process.info(self())[:registered_name]), message)
  end
  def write_to(target, tag, name, message) do
    spawn fn() ->
      auth_token = target.auth.identity
      tag = Atom.to_string(tag)
      packet_length = String.length(auth_token <> name <> tag <> message)
      parsed_message = "#{packet_length}{#{auth_token}░#{name}░#{tag}░#{String.strip(message)}}"

      pid = Process.whereis(String.to_atom("events_" <> target.id))

      if pid do
        case target.protocol do
          :tcp -> write_to_tcp(target, parsed_message)
          :udp -> write_to_udp(target, parsed_message)
          :web -> write_to_web(target, parsed_message)
        end
      end
      Process.exit(self, :normal)
    end
  end

  def write_to_tcp(target, message) do
    target.port |> Socket.Stream.send! message
  end

  def write_to_udp(target, message) do
    target.port |> Socket.Datagram.send! message, {target.ip, String.to_integer(target.id)}
  end

  def write_to_web(target, message) do
    target.port |> Socket.Web.send!({:text, message})
  end
end
