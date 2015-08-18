defmodule Moongate.ClientEvent do
  defstruct cast: nil, error: nil, origin: nil, params: nil, to: nil
end

defmodule Moongate.EventListener do
  defstruct id: nil, origin: nil
end

defmodule Moongate.Events.Listener do
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.SocketWriter
  use Moongate.Macros.Worlds

  def start_link(origin) do
    id = origin.id

    link(%Moongate.EventListener{id: id, origin: origin}, "events", "#{id}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Event listener for client #{state.id} has been started.", :green)
    apply(world_module, :connected, [%Moongate.StageTransaction{ origin: state.origin }])

    {:noreply, state}
  end

  @doc """
    Authenticate with the given params.
  """
  def handle_cast({:auth, token}, state) do
    {:noreply, %{ state | origin: %{ state.origin | auth: token } }}
  end

  @doc """
    Deliver a parsed socket message to the appropriate server.
  """
  def handle_cast({:event, message, token, socket}, state) do
    authenticated = authenticated?(state, token)

    case message do
      [to | [cast | params]] ->
        handle_message(state.origin, cast, params, to, authenticated)
      _ ->
        Moongate.Scopes.Events.take(message)
    end

    {:noreply, state}
  end

  def handle_message(origin, cast, params, to, authenticated) do
    event = %Moongate.ClientEvent{
      cast: String.to_atom(cast),
      to: String.to_atom(to),
      params: List.to_tuple(params),
      origin: origin
    }

    case event do
      %{ cast: :login, to: :auth } when not authenticated ->
        tell_async(:auth, {:login, event})

      %{ cast: :register, to: :auth } when not authenticated ->
        tell_async(:auth, {:register, event})

      %{ cast: any, to: stage} ->
        tell_async(:stage, stage, {:tunnel, event})

      _ ->
        Moongate.Scopes.Events.take(event)
    end
  end

  defp authenticated?(state, token) do
    token != "anon" and state.origin.auth.identity == token
  end
end
