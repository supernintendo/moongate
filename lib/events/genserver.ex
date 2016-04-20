defmodule Moongate.Event.GenServer do
  @moduledoc """
    Provides functionality for an event process.
    Event processes are responsible for sending and
    receiving messages to and from a client.
  """
  import Moongate.Macros.SocketWriter
  import Moongate.Event.Mutations
  use GenServer
  use Moongate.Macros.Mutations, genserver: true
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  ### Public

  @doc """
    Start the event process with the origin and its id
    used for the initial state.
  """
  def start_link(origin) do
    %Moongate.Event.GenServer.State{
      id: origin.id,
      origin: origin
    }
    |> link
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    %Moongate.StageEvent{
      origin: state.origin
    }
    |> Moongate.Worlds.world_apply(:connected)
    |> mutations(state)
    |> Map.put(:origin, %{ state.origin | events: self })
    |> no_reply
  end

  @doc """
    Send a packet to the origin with its authentication
    identifier to let it know it has successfully logged in.
  """
  def handle_cast({:auth, token}, state) do
    write_to(state.origin, :set_token, "event", "#{token.identity}")
    {:noreply, %{ state | origin: %{ state.origin | auth: token } }}
  end

  @doc """
    Accept a list of strings which represent the parts of
    an incoming packet message and pass it off if it is
    valid.
  """
  def handle_cast({:event, message, socket}, state) do
    authorized = is_authorized?(socket, state)

    case message do
      message when authorized and is_list(message) -> handle_message(message, state)
      _ -> Moongate.Say.pretty("#{state.origin.auth.identity} - rejecting bad packet.", :red)
    end
    {:noreply, state}
  end

  @doc """
    Let every stage know to remove references to this event
    process and tell the auth process to deauthenticate
    this event's origin. This happens when the client
    logs out, disconnects, etc.
  """
  def handle_call(:cleanup, _from, state) do
    event = %Moongate.ClientEvent{
      origin: state.origin
    }
    Enum.map(state.stages, fn(stage) ->
      tell({:depart, event}, :"stage_#{Atom.to_string(stage)}")
    end)
    tell({:deauth, state.origin.id}, :auth)

    {:reply, :ok, state}
  end

  @doc """
    Prepare a packet to send to this event process' origin socket.
    `tag` generally represents the process or domain that the
    message relates to, `name` refers to the name of the event
    and `message` is the rest of the message body (typically
    parameters).
  """
  def handle_cast({:write, tag, name, message}, state) do
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

    write(state.origin.protocol, state.origin, parsed_message)

    {:noreply, state}
  end

  ### Private

  # Parse a message, a list of strings representing the
  # parts of a socket message, and pass it to the function
  # which handles it (or do nothing with it if no function
  # is defined which can handle it)
  defp handle_message(message, state) do
    message
    |> Moongate.Event.Service.scope_message
    |> use_message(state)
  end

  # Using the stage which is currently set as the target
  # stage, return the name of the pool process that a
  # message should be delivered to.
  def target_process(message, state) do
    state.target_stage
    |> Moongate.Pool.Service.pool_process(
      message
      |> Moongate.Event.Service.delimited_values
      |> hd
    )
  end

  # Check whether the socket sending a message is
  # the same socket defined in the origin associated
  # with this event process.
  defp is_authorized?(socket, state) do
    {port, _protocol} = socket

    state.origin.port == port
  end

  # Pass a message off to the target pool to be used
  # for behavior defined within a deed (deeds contain
  # functions which are used to interact with members
  # of pools).
  defp use_message({:deed, message}, state) do
    {:use_deed, %Moongate.ClientEvent{
      cast: message |> tl |> hd,
      to: message |> target_process(state),
      params: message |> tl |> tl |> List.to_tuple,
      origin: state.origin,
      use_deed: message |> hd |> String.split(".") |> tl |> hd
    }}
    |> tell(target_process(message, state))
  end

  # Pass a message off to the target pool to be used
  # for functions within all deeds.
  defp use_message({:pool, message}, state) do
    {:use_all_deeds,
     %Moongate.ClientEvent{
       cast: message |> tl |> hd,
       to: message |> target_process(state),
       params: message |> tl |> tl |> List.to_tuple,
       origin: state.origin
     }}
    |> tell(target_process(message, state))
  end

  # Pass a message off to a named process.
  defp use_message({:process, message}, state) do
    target = message |> hd |> String.to_atom

    {message |> tl |> hd,
     %Moongate.ClientEvent{
       cast: message |> tl |> hd,
       to: target,
       params: message |> tl |> tl |> List.to_tuple,
       origin: state.origin
     }}
    |> tell(target)
  end

  # Pass a message off to the stage currently marked
  # as the target stage.
  defp use_message({:stage, message}, state) do
    {:tunnel,
     %Moongate.ClientEvent{
       cast: message |> hd,
       to: state.target_stage,
       params: message |> tl |> List.to_tuple,
       origin: state.origin
     }}
    |> tell("stage", state.target_stage)
  end

  # Do nothing. This happens when the original packet
  # sent by the client was not formatted correctly or
  # understood.
  defp use_message({:none}, _state) do
  end

  # Write to a TCP socket.
  defp write(:tcp, target, message) do
    target.port |> Socket.Stream.send!(message)
  end

  # Write to a UDP socket.
  defp write(:udp, target, message) do
    target.port |> Socket.Datagram.send!(message, {target.ip, String.to_integer(target.id)})
  end

  # Write to a WebSocket.
  defp write(:web, target, message) do
    target.port |> Socket.Web.send!({:text, message})
  end

  # Fallback for when protocol is not one of the others.
  defp write(protocol, target, message) do
  end
end
