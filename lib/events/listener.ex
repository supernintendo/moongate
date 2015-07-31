defmodule ClientEvent do
  defstruct cast: nil, contents: nil, error: nil, origin: nil, to: nil
end

defmodule EventListener do
  defstruct auth: nil,
            id: nil
end

defmodule Events.Listener do
  use Macros.Packets
  use Macros.SocketWriter
  use Macros.Store
  use Macros.Translator

  def start_link(id) do
    link(%EventListener{id: id}, "events", "#{id}")
  end

  def handle_cast({:init}, state) do
    Say.pretty("Event listener for client #{state.id} has been started.", :green)
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
    event = from_list(message, socket, state.id)

    case event do
      %{ cast: :login, to: :auth } ->
        p = expect_from(event, {:email, :password})
        tell_async(:auth, {:login, p, self()})

      %{ cast: :register, to: :auth } ->
        p = expect_from(event, {:email, :password})
        tell_async(:auth, {:register, p})

      _ ->
        Scopes.Events.take(event)
    end

    {:noreply, state}
  end

  defp authenticated?(state, token) do
    state.auth == token
  end
end
