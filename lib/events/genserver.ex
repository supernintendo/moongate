defmodule Moongate.Events.Listener do
  @moduledoc """
    Provides functionality for a Moongate Event Listener.
  """
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  ### Public

  @doc """
    Start a Moongate.Events.Listener GenServer.
  """
  def start_link(origin) do
    %Moongate.EventListener{
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
    |> Map.put(:origin, %{ state.origin | events_listener: self })
    |> no_reply
  end

  @doc """
    Authenticate with the given params.
  """
  def handle_cast({:auth, token}, state) do
    write_to(state.origin, :set_token, "events", "#{token.identity}")
    {:noreply, %{ state | origin: %{ state.origin | auth: token } }}
  end

  @doc """
    Accept an incoming message.
  """
  def handle_cast({:event, message, socket}, state) do
    authenticated = is_authenticated?(socket, state)

    case message do
      message when is_list(message) ->
        handle_message(message, state)
      _ ->
        Moongate.Say.pretty("#{state.origin.auth.identity} - rejecting packet from socket I don't trust.", :red)
    end
    {:noreply, state}
  end

  @doc """
    Clean up.
  """
  def handle_call(:cleanup, _from, state) do
    event = %Moongate.ClientEvent{
      origin: state.origin
    }
    Enum.map(state.stages, fn(stage) ->
      tell({:depart, event}, String.to_atom("stage_#{Atom.to_string(stage)}"))
    end)
    tell({:deauth, state.origin.id}, :auth)

    {:reply, :ok, state}
  end

  @doc """
    Handle mutations.
  """
  def handle_call({:mutations, event}, _from, state) do
    event
    |> mutations(state)
    |> reply(:ok)
  end

  ### Private

  # Parse a message and return a %Moongate.ClientEvent
  defp handle_message(message, state) do
    message
    |> Moongate.Events.scope_message
    |> IO.inspect
    |> use_message(state)
  end

  # Get the target process for the message.
  def target_process(message, state) do
    state.target_stage
    |> Moongate.Service.Pools.pool_process(message |> Moongate.Events.delimited_values |> hd)
  end

  # Check whether a socket is qualified to send messages
  # to this event listener.
  defp is_authenticated?(socket, state) do
    {port, _protocol} = socket

    state.origin.port == port
  end

  # Check whether the identity of the token matches that
  # of the origin of this event listener.
  defp is_logged_in?(state) do
    state.origin.auth.identity != "anon"
  end

  defp mutations(event, state) do
    (for mut <- event.mutations, do: mutation(mut, event, state))
    |> Enum.into(state)
  end

  defp mutation({:join_stage, stage_name}, event, state) do
    Moongate.Service.Stages.arrive(event.origin, stage_name)

    {:stages, state.stages ++ [stage_name]}
  end

  defp mutation({:leave_from, origin}, event, state) do
    {:stages, Enum.filter(state.stages, &(&1 != event.from)) }
  end

  defp mutation({:set_target_stage, stage_name}, _event, state) do
    {:target_stage, stage_name}
  end

  # Do nothing.
  defp use_message({:none}, _state) do
  end

  # Pass the message off to the target pool
  # to be used for functions within a specific
  # deed.
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

  # Pass the message off to the target pool
  # to be used for functions within all deeds.
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

  # Pass the message off to the current
  # target stage.
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
end
