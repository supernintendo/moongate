defmodule Moongate.AuthSessions do
  @moduledoc """
    Represents the state of the Moongate.Auth GenServer.
    `sessions` is a map of Moongate.AuthSessions with the ids
    of Moongate.SocketOrigins as keys.
  """
  defstruct anonymous: false, sessions: %{}
end

defmodule Moongate.AuthSession do
  @moduledoc """
    Represents a single auth session.
  """
  defstruct email: nil, identity: "anon"
end

defmodule Moongate.Auth do
  @moduledoc """
    Provides the behavior for the Moongate Auth GenServer. A
    %Moongate.AuthSessions is kept as state. This module
    primarily deals with authenticating users and allowing
    account creation.
  """
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.Processes

  ### Public

  @doc """
    Start the Moongate.Auth GenServer.
  """
  def start_link(config) do
    if config["anonymous"] do
      link(%Moongate.AuthSessions{anonymous: true}, "auth")
    else
      link(%Moongate.AuthSessions{}, "auth")
    end
  end

  @doc """
    Check whether a Moongate.SocketOrigin is authenticated.
  """
  def handle_call({:check_auth, origin}, _from, state) do
    has_id = Map.has_key?(state.sessions, origin.id)
    origin_logged_in = Map.has_key?(origin.auth, :identity)

    if has_id and origin_logged_in do
      session = Map.get(state.sessions, origin.id)

      {:reply, {:ok, (session.identity == origin.auth.identity)}, state}
    else
      {:reply, {:ok, false}, state}
    end
  end

  @doc """
    Attempt to login with the provided credentials.
  """
  def handle_cast({"login", event}, state) do
    state = event.params
    |> authenticate(state)
    |> finalize_login(event, state)

    if Map.has_key?(state.sessions, event.origin.id) do
      {:auth, state.sessions[event.origin.id]}
      |> tell_pid(event.origin.events_listener)
    end

    {:noreply, state}
  end

  def handle_cast({:deauth, id}, state) do
    if Map.has_key?(state.sessions, id) do
      {:noreply, %{ state | sessions: state.sessions |> Map.delete(id) }}
    else
      {:noreply, state}
    end
  end

  @doc """
    Check if a user is logged in by email.
  """
  def handle_cast({:is_logged_in, event}, state) do
    {email} = event.params

    if Map.has_key?(state.sessions, email) do
      write_to(event.origin, :info, "User is logged in.")
    else
      write_to(event.origin, :info, "User is not logged in.")
    end

    {:noreply, state}
  end

  @doc """
    Create a new account with the given params if we're allowed.
  """
  def handle_cast({:register, event}, state) do
    {email, password} = event.params
    {status, _} = create_account(email, password)

    if status == :ok do
      IO.puts "Account for #{email} created."

      write_to(event.origin, :info, "Your account has been created.")
    else
      write_to(event.origin, :info, "Error creating account for #{email}.")
    end

    {:noreply, state}
  end

  ### Private

  # Attempt authentication, allowing anonymous
  # authentication if the current world config.json
  # permits it.
  defp authenticate({email, password}, state) do
    if state.anonymous do
      {:ok, "You have anonymously logged in."}
    else
      email
      |> find_email
      |> validate(password)
    end
  end

  # Attempt to create a %Moongate.Db.User with the
  # given params.
  defp create_account(email, password) do
    Moongate.Db.UserQueries.create([
      email: email,
      password: password
    ])
  end

  # Mutates state by assigning a new %Moongate.AuthSession
  # to its sessions map, using the %Moongate.EventListener
  # id as the key.
  defp create_session(state, {email, _}, id) do
    session = %Moongate.AuthSession{
      email: email,
      identity: UUID.uuid4(:hex)
    }
    %{state | sessions: Map.put(state.sessions, id, session)}
  end

  # Given the result of a login attempt from `authenticate`,
  # return a message indicating whether or not the
  # login attempt was successful.
  defp finalize_login(result, event, state) do
    case result do
      {:ok, message} ->
        state
        |> create_session(event.params, event.origin.id)
      {:error, message} ->
        write_to(event.origin, :info, message)
        state
      _ ->
        state
    end
  end

  # Takes an email and returns the %Moongate.Db.User
  # with that email.
  defp find_email(email) do
    Moongate.Db.UserQueries.find_by_email(email)
    |> List.first
  end

  # Takes a %Moongate.Db.User and a password,
  # returning an authentication message depending
  # on the result of `hash`
  defp validate(user, password) do
    cond do
      user == nil ->
        {:error, "The user account for that email doesn't exist."}
      hash(user, password) == user.password ->
        {:ok, "You have successfully logged in."}
      true ->
        {:error, "The password you entered is incorrect."}
    end
  end

  # Takes a %Moongate.Db.User and a password,
  # hashing the password using the salt on the
  # user record, and matching it against the
  # password on the user record.
  defp hash(user, password) do
    :pbkdf2.pbkdf2(:sha256, password, user.password_salt, 4096)
  end
end