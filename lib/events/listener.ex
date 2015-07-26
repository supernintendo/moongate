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

      %{ cast: :key, to: :game } ->
        authenticated_action(event, token, state)

      _ ->
       IO.puts "Socket message received: #{message}"
    end

    {:noreply, state}
  end

  # Handle a socket message from an authenticated client.
  defp authenticated_action(event, token, state) do
    can_pass = authenticated?(state, token)

    if can_pass do
      case event do
        %{ cast: :key, to: :game } ->
          p = expect_from(event, {:key})
          tell_async(:entity, "#{event.origin.id}", {:keypress, p})
        _ ->
          nil
      end
    else
      write_to(event.origin, %{
        cast: :error,
        namespace: :global,
        value: "Not authenticated."
      })
    end
  end

  defp authenticated?(state, token) do
    state.auth == token
  end

  # Coerce a packet list into a map with keynames.
  defp expect_from(event, schema) do
    results = Enum.reduce(
      Enum.map(0..length(Tuple.to_list(schema)) - 1,
              fn(i) -> Map.put(%{}, elem(schema, i), elem(event.contents, i)) end),
      fn(first, second) -> Map.merge(first, second) end)

    %{event | contents: results}
  end
end
