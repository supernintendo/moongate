defmodule Moongate.ClientEvent do
  defstruct(
    cast: nil,
    error: nil,
    origin: nil,
    params: nil,
    to: nil
  )
end

defmodule Moongate.EventListener do
  defstruct id: nil, origin: nil, stages: []
end

defmodule Moongate.Events.Listener do
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  def start_link(origin) do
    id = origin.id

    link(%Moongate.EventListener{id: id, origin: origin}, "events", "#{id}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Event listener for client #{state.id} has been started.", :green)
    apply(world_module, :connected, [%Moongate.StageEvent{ origin: state.origin }])

    origin = %{state.origin | events_listener: self}
    {:noreply, %{state | origin: origin}}
  end

  @doc """
    Clean up
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
      [to | [cast | params]] when authenticated ->
        handle_message(state.origin, cast, params, to, logged_in)
      _ when authenticated ->
        Moongate.Scopes.Events.take(message)
      _ ->
        Moongate.Say.pretty """
          #{state.origin.auth.identity} - rejecting packet from socket I don't trust.
        """, :red
    end

    {:noreply, state}
  end

  def handle_cast({:arrive, stage_name}, state) do
    {:noreply, %{state | stages: state.stages ++ [stage_name]}}
  end

  def handle_cast({:depart, stage_name}, state) do
    {:noreply, %{state | stages: Enum.filter(state.stages, &(&1 != stage_name))}}
  end

  @doc """
    Handle an incoming, trusted message.
  """
  def handle_message(origin, cast, params, to, logged_in) do
    event = %Moongate.ClientEvent{
      cast: String.to_atom(cast),
      to: String.to_atom(to),
      params: List.to_tuple(params),
      origin: origin
    }
    case event do
      %{ cast: :login, to: :auth } when not logged_in -> tell_async(:auth, {:login, event})
      %{ cast: :register, to: :auth } when not logged_in -> tell_async(:auth, {:register, event})
      %{ cast: any, to: stage} -> tell_async(:stage, stage, {:tunnel, event})
      _ -> Moongate.Scopes.Events.take(event)
    end
  end

  # Check whether a socket is qualified to send messages
  # to this event listener.
  defp is_authenticated?(socket, state) do
    {port, protocol} = socket

    state.origin.port == port
  end

  # Check whether the identity of the token matches that
  # of the origin of this event listener.
  defp is_logged_in?(state) do
    state.origin.auth.identity != "anon"
  end
end
