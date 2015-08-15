defmodule Moongate.ClientEvent do
  defstruct cast: nil, contents: nil, error: nil, origin: nil, to: nil
end

defmodule Moongate.EventListener do
  defstruct auth: nil,
            id: nil
end

defmodule Moongate.Events.Listener do
  use Moongate.Macros.Packets
  use Moongate.Macros.SocketWriter
  use Moongate.Macros.Store
  use Moongate.Macros.Translator

  def start_link(id) do
    link(%Moongate.EventListener{id: id}, "events", "#{id}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Event listener for client #{state.id} has been started.", :green)
    {:noreply, state}
  end

  @doc """
    Authenticate with the given params.
  """
  def handle_cast({:auth, updated}, state) do
    {:noreply, Map.merge(state, %{auth: updated})}
  end

  @doc """
    Deliver a parsed socket message to the appropriate server.
  """
  def handle_cast({:event, message, token, socket}, state) do
    authenticated = authenticated?(state, token)
    event = from_list(message, socket, state.id)

    case event do
      %{ cast: :login, to: :auth } when not authenticated ->
        p = expect_from(event, {:email, :password})
        tell_async(:auth, {:login, p, self()})

      %{ cast: :register, to: :auth } when not authenticated ->
        p = expect_from(event, {:email, :password})
        tell_async(:auth, {:register, p})

      _ ->
        Moongate.Scopes.Events.take(event)
    end

    {:noreply, state}
  end

  defp authenticated?(state, token) do
    state.auth == token
  end
end
