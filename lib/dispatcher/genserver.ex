defmodule Moongate.Dispatcher.GenServer do
  use GenServer
  use Moongate.Macros.Processes

  @moduledoc """
    Provides functionality for a packet dispatcher.
  """

  ### Public

  @doc """
    Start the packet dispatcher.
  """
  def start_link(origin) do
    %{}
    |> link
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    state
    |> no_reply
  end

  def handle_cast({:write, target, tag, name, message}, state) do
    timestamp = Moongate.Time.current_ms
    tag = Atom.to_string(tag)

    if is_list(message) do
      parts = Enum.map(message, &Moongate.Atoms.to_strings/1)
      parsed_parts = String.strip(Enum.join(parts, "·"))
      packet_length = byte_size("#{timestamp}" <> name <> tag <> List.to_string(parts))
      parsed_message = "#{packet_length}{#{timestamp}·#{name}·#{tag}·#{parsed_parts}}"
    else
      packet_length = byte_size("#{timestamp}" <> name <> tag <> message)
      parsed_message = "#{packet_length}{#{timestamp}·#{name}·#{tag}·#{String.strip(message)}}"
    end

    case target.protocol do
      :tcp -> write_to_tcp(target, parsed_message)
      :udp -> write_to_udp(target, parsed_message)
      :web -> write_to_web(target, parsed_message)
    end

    {:noreply, state}
  end

  defp write_to_tcp(target, message) do
    target.port |> Socket.Stream.send!(message)
  end

  defp write_to_udp(target, message) do
    target.port |> Socket.Datagram.send!(message, {target.ip, String.to_integer(target.id)})
  end

  defp write_to_web(target, message) do
    target.port |> Socket.Web.send!({:text, message})
  end
end
