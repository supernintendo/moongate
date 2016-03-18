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

  defp create_session(state, {email, _}, id) do
    session = %Moongate.AuthSession{
      email: email,
      identity: UUID.uuid4(:hex)
    }
    %{state | sessions: Map.put(state.sessions, id, {email, session})}
  end

  defp tell_player(state, event, message) do
    write_to(event.origin, :info, message)
    tell_async(:events, event.origin.id, {:auth, state.sessions[event.origin.id]})
    # Moongate.Say.pretty("#{Moongate.Say.origin(event.origin.id)} logged in.", :green)
    state
  end

  defp finalize_login(result, event, state) do
    case result do
      {:ok, message} ->
        state
        |> create_session(event.params, event.origin.id)
        |> tell_player(event, message)
      {:error, message} ->
        write_to(event.origin, :info, message)
        # Moongate.Say.pretty("Failed log in attempt from anonymous #{Moongate.Say.origin(event.origin)} connection.", :red)
        state
      _ ->
        state
    end
  end

  @doc """
    Attempt to login with the provided credentials.
  """
  def handle_call({:login, event}, _from, state) do
    state = event.params
    |> authenticate(state)
    |> finalize_login(event, state)

    {:reply, {:ok}, state}
  end

  @doc """
    Check whether a Moongate.SocketOrigin is authenticated.
  """
  def handle_call({:check_auth, origin}, _from, state) do
    has_id = Map.has_key?(state.sessions, origin.id)
    origin_logged_in = Map.has_key?(origin.auth, :identity)

    if has_id and origin_logged_in do
      {_email, identity} = Map.get(state.sessions, origin.id)
      is_authenticated = identity == origin.auth.identity

      {:reply, {:ok, is_authenticated}, state}
    else
      {:reply, {:ok, false}, state}
    end
  end

  @doc """
    Check if a user is logged in by email.
  """
  def handle_cast({:is_logged_in, event}, state) do
    {email} = event.params
    logged_in = Map.has_key?(state.sessions, email)
    if logged_in do
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

  # Check if the requested login is correct.
  defp authenticate({email, password}, state) do
    if state.anonymous do
      auth_status = {:ok, "You have anonymously logged in."}
    else
      email
      |> find_emails_that_match
      |> List.first
      |> validate(password)
    end
  end

  defp find_emails_that_match(email) do
    Moongate.Db.UserQueries.find_by_email(email)
  end

  # Given an email and password, validate an email using the email's salt.
  defp validate(email, password) do
    if email == nil do
      {:error, "The user account for that email doesn't exist."}
    else
      {:ok, encrypted_pass} = :pbkdf2.pbkdf2(:sha256, password, email.password_salt, 4096)

      if :pbkdf2.to_hex(encrypted_pass) == email.password do
        {:ok, "You have successfully logged in."}
      else
        {:error, "The password you entered is incorrect."}
      end
    end
  end

  # Attempt to create an account with the given params.
  defp create_account(email, password) do
    Moongate.Db.UserQueries.create([
      email: email,
      password: password
    ])
  end
end
