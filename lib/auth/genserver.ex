defmodule Moongate.Auth.GenServer do
  @moduledoc """
    Handles all authentication requests as well
    as account creation.
  """
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.Processes

  ### Public

  @doc """
    Start the authentication GenServer and initialize
    state with the anonymous flag if it is set in the
    current world's config.json - this effectively
    causes authentication to be bypassed and is mostly
    used for testing.
  """
  def start_link(config) do
    if config.anonymous do
      %Moongate.Auth.GenServer.State{
        anonymous: true
      }
      |> link("auth")
    else
      %Moongate.Auth.GenServer.State{}
      |> link("auth")
    end
  end

  @doc """
    Checks to see if an origin has the same id as
    an authenticated session and that the origin
    has been assigned an identifier equal to that
    of the session.
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
    Query the database with the username and password
    provided by the params of an event. If the username and
    password are correct, add a session for the event's
    origin to the GenServer state and notify the event
    process making the request.
  """
  def handle_cast({"login", event}, state) do
    state = event.params
    |> authenticate(state)
    |> finalize_login(event, state)

    if Map.has_key?(state.sessions, event.origin.id) do
      {:auth, state.sessions[event.origin.id]}
      |> tell_pid(event.origin.events)
    end

    {:noreply, state}
  end

  @doc """
    Given the id of an origin, remove that id from the
    sessions list if it exists, effectively treating it
    as unauthenticated (as in the case of logging out,
    for example).
  """
  def handle_cast({:deauth, id}, state) do
    if Map.has_key?(state.sessions, id) do
      {:noreply, %{ state | sessions: state.sessions |> Map.delete(id) }}
    else
      {:noreply, state}
    end
  end

  @doc """
    Check the sessions list for the email provided
    by the params of an event and send a packet indicating
    login status for the origin with that email.
  """
  def handle_cast({:is_logged_in, event}, state) do
    {email} = event.params

    if Map.has_key?(state.sessions, email) do
      write_to(event.origin, :info, "auth", "User is logged in.")
    else
      write_to(event.origin, :info, "auth", "User is not logged in.")
    end

    {:noreply, state}
  end

  @doc """
    Try to create a new account with the given params
    and send a packet to the origin indicating whether
    or not account creation was successful.
  """
  def handle_cast({:register, event}, state) do
    {email, password} = event.params
    {status, _} = create_account(email, password)

    if status == :ok do
      IO.puts "Account for #{email} created."

      write_to(event.origin, :info, "auth", "Your account has been created.")
    else
      write_to(event.origin, :info, "auth", "Error creating account for #{email}.")
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

  # Mutates state by assigning a new session to its
  # sessions map, using the event process' id
  # as the key.
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
        {username, _password} = event.params
        [:bright, username]
        ++ [IO.ANSI.reset]
        ++ [" has "]
        ++ [:green, "logged in"]
        ++ [IO.ANSI.reset]
        ++ ["."]
        |> Moongate.Say.ansi([timestamp: true])

        state
        |> create_session(event.params, event.origin.id)
      {:error, message} ->
        write_to(event.origin, :info, "auth", message)
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
        {:error, "The account with that name does not exist."}
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
