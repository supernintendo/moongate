defmodule Moongate.ClientEvent do
  @moduledoc """
    Represents a Moongate.Events.Listener's SocketOrigin,
    as well as information related to packets received by
    the socket connection.
  """
  defstruct(
    cast: nil,
    error: nil,
    origin: nil,
    params: nil,
    to: nil,
    use_deed: nil
  )
end

defmodule Moongate.EventListener do
  @moduledoc """
    Represents the state of a Moongate.Events.Listener
    GenServer.
  """
  defstruct id: nil, origin: nil, stages: [], target_stage: nil
end

defmodule Moongate.Events.Listener do
  @moduledoc """
    Provides functionality for a Moongate Event Listener.
  """
  alias Moongate.Service.Pools, as: Pools
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  @doc """
    Start a Moongate.Events.Listener GenServer.
  """
  def start_link(origin) do
    id = origin.id

    link(%Moongate.EventListener{id: id, origin: origin}, "events", "#{id}")
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Event listener for client #{state.id} has been started.", :green)
    {:ok, result} = apply(world_module, :connected, [%Moongate.StageEvent{ origin: state.origin }])
    origin = %{state.origin | events_listener: self}
    {:noreply, %{state | origin: origin, stages: [result.from], target_stage: result.from}}
  end

  @doc """
    Authenticate with the given params.
  """
  def handle_cast({:auth, token}, state) do
    write_to(state.origin, :set_token, "#{token.identity}")
    {:noreply, %{ state | origin: %{ state.origin | auth: token } }}
  end

  @doc """
    Accept an incoming message.
  """
  def handle_cast({:event, message, socket}, state) do
    authenticated = is_authenticated?(socket, state)
    logged_in = is_logged_in?(state)

    case message do
      ["auth" | [cast | params]] when authenticated -> handle_auth_message(state.origin, cast, params, logged_in)
      message when is_list(message) -> handle_message(message, state)
      _ when authenticated -> Moongate.Scopes.Events.take(message)
      _ -> Moongate.Say.pretty "#{state.origin.auth.identity} - rejecting packet from socket I don't trust.", :red
    end
    {:noreply, state}
  end

  @doc """
    Received whenever a player leaves a stage.
  """
  def handle_call({:depart, stage_name}, _from, state) do
    {:reply, :ok, %{state | stages: Enum.filter(state.stages, &(&1 != stage_name))}}
  end

  @doc """
    Clean up.
  """
  def handle_call(:cleanup, _from, state) do
    event = %Moongate.ClientEvent{
      origin: state.origin
    }
    Enum.map(state.stages, fn(stage) ->
      tell_async(String.to_atom("stage_#{Atom.to_string(stage)}"), {:depart, event})
    end)
    {:reply, nil, state}
  end

  @doc """
    Received whenever a player joins a stage.
  """
  def handle_call({:arrive, stage_name, :set_as_target}, _from, state) do
    handle_call({:arrive, stage_name}, _from, %{state | target_stage: stage_name})
  end

  @doc """
    Received whenever a player joins a stage.
  """
  def handle_call({:arrive, stage_name}, _from, state) do
    {:reply, :ok, %{state | stages: state.stages ++ [stage_name]}}
  end

  def handle_message(message, state) do
    head = List.first(message)

    if head != nil do
      codepoints = String.codepoints(head)
      has_context = Regex.match?(~r/^[A-Z]$/, hd(codepoints))

      if has_context do
        context = String.split(head, ".")

        if length(context) == 2 do
          process = Pools.pool_process(state.target_stage, hd(context))
          parts = String.split(hd(message), ".")
          event = %Moongate.ClientEvent{
            cast: hd(tl(message)),
            to: process,
            params: List.to_tuple(tl(tl(message))),
            origin: state.origin,
            use_deed: hd(tl(parts))
          }
          tell_async(process, {:use_deed, event})
        else
          process = Pools.pool_process(state.target_stage, hd(context))
          parts = String.split(hd(message), ".")
          event = %Moongate.ClientEvent{
            cast: hd(tl(message)),
            to: process,
            params: List.to_tuple(tl(tl(message))),
            origin: state.origin
          }
          tell_async(process, {:use_all_deeds, event})
        end
      else
        event = %Moongate.ClientEvent{
          cast: hd(message),
          to: state.target_stage,
          params: List.to_tuple(tl(message)),
          origin: state.origin
        }
        tell_async(state.target_stage, {:tunnel, event})
      end
    end
  end

  @doc """
    Handle an incoming, trusted message.
  """
  def handle_auth_message(origin, cast, params, logged_in) do
    event = %Moongate.ClientEvent{
      cast: String.to_atom(cast),
      to: :auth,
      params: List.to_tuple(params),
      origin: origin
    }
    case event do
      %{ cast: :login, to: :auth } when not logged_in -> tell_sync(:auth, {:login, event})
      %{ cast: :register, to: :auth } when not logged_in -> tell_async(:auth, {:register, event})
      %{ cast: :is_logged_in, to: :auth } -> tell_async(:auth, {:is_logged_in, event})
      _ -> nil
      # %{ cast: _any, to: stage} -> tell_async(:stage, stage, {:tunnel, event})
      # _ -> Moongate.Scopes.Events.take(event)
    end
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
end
