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

  defmacro world_events do
    {:ok, read} = File.read "config/config.json"
    {:ok, config} = JSON.decode(read)
    world = config["world"] || "default"
    {:ok, read} = File.read "worlds/#{world}/events.json"
    {:ok, events} = JSON.decode(read)

    Enum.map events, fn({event, params}) ->
      event = String.to_atom(event)
      namespace = String.to_atom(params["namespace"])
      arguments = Enum.map params["arguments"], String.to_atom

      quote do
        %{ cast: unquote(event), to: unquote(namespace) } ->
          p = expect_from(event, unquote(List.to_tuple(arguments)))
          tell_async(unquote(namespace), {unquote(event), p})
      end
    end
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

      world_events

      _ ->
       IO.puts "Socket message received: #{message}"
    end

    {:noreply, state}
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
