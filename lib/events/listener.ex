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

  ### Public

  @doc """
    Start a Moongate.Events.Listener GenServer.
  """
  def start_link(origin) do
    %Moongate.EventListener{
      id: origin.id,
      origin: origin
    }
    |> link("events", "#{origin.id}")
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    %Moongate.StageEvent{
      origin: state.origin
    }
    |> Moongate.Worlds.world_apply(:connected)
    |> elem(1)          # TODO: remove this by eliminating tuple from last ret
    |> initialize_state(state)
    |> no_reply
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

    case message do
      ["auth" | [cast | params]] when authenticated ->
        handle_auth_message(state, cast, params)
      message when is_list(message) ->
        handle_message(message, state)
      _ ->
        Moongate.Say.pretty("#{state.origin.auth.identity} - rejecting packet from socket I don't trust.", :red)
    end
    {:noreply, state}
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
    {:reply, nil, state}
  end

  @doc """
    Received whenever a player leaves a stage.
  """
  def handle_call({:depart, stage_name}, _from, state) do
    {:reply, :ok, %{state | stages: Enum.filter(state.stages, &(&1 != stage_name))}}
  end

  ### Private

  # Parse a message and return a %Moongate.ClientEvent
  defp handle_message(message, state) do
    message
    |> Moongate.Events.scope_message
    |> use_message(state)
  end

  # Get the target process for the message.
  def target_process(message, state) do
    state.target_stage
    |> Pools.pool_process(message |> Moongate.Events.delimited_values |> hd)
  end

  # Handle an incoming, trusted message.
  defp handle_auth_message(state, cast, params) do
    event = %Moongate.ClientEvent{
      cast: String.to_atom(cast),
      to: :auth,
      params: List.to_tuple(params),
      origin: state.origin
    }
    logged_in = is_logged_in?(state)

    case event do
      %{ cast: :login, to: :auth } when not logged_in ->
        tell!({:login, event}, :auth)
      %{ cast: :register, to: :auth } when not logged_in ->
        tell({:register, event}, :auth)
      %{ cast: :is_logged_in, to: :auth } ->
        tell({:is_logged_in, event}, :auth)
      _ ->
        nil
    end
  end

  # Mutate state with the result of the &connected/1
  # function being called within the entry module of
  # the current world. This happens on server start.
  defp initialize_state(result, state) do
    %{ state |
       stages: [result.from],
       target_stage: result.from,
       origin: %{
         state.origin | events_listener: self
       }
     }
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
    |> tell(message |> target_process(state))
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
    |> tell(message |> target_process(state))
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
    |> tell(state.target_stage)
  end
end
