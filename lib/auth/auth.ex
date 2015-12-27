defmodule Moongate.AuthSessions do
  defstruct anonymous: false, tokens: %{}
end

defmodule Moongate.AuthToken do
  defstruct email: nil, identity: "anon"
end

# The Auth module manages login and new account creation.
defmodule Moongate.Auth do
  import Moongate.Macros.SocketWriter
  use GenServer
  use Moongate.Macros.Processes

  def start_link(config) do
    if config["anonymous"] do
      link(%Moongate.AuthSessions{anonymous: true}, "auth")
    else
      link(%Moongate.AuthSessions{}, "auth")
    end
  end

  @doc """
    Check if a user is logged in by email.
  """
  def handle_cast({:is_logged_in, event}, state) do
    {email} = event.params
    logged_in = Enum.any?(state.tokens, fn({key, {token_email, identity}}) ->
      token_email == email
    end)
    if logged_in do
      write_to(event.origin, :sys_message, "User is logged in.")
    else
      write_to(event.origin, :sys_message, "User is not logged in.")
    end
    {:noreply, state}
  end

  @doc """
    Attempt to login with the provided credentials.
  """
  def handle_cast({:login, event}, state) do
    {email, password} = event.params

    if state.anonymous do
      auth_status = {:ok, "You have anonymously logged in."}
    else
      auth_status = authenticate(email, password)
    end

    case auth_status do
      {:ok, message} ->
        token = %Moongate.AuthToken{email: email, identity: UUID.uuid4(:hex)}
        state = %{state | tokens: Map.put(
          state.tokens,
          String.to_atom(event.origin.id),
          {email, token.identity}
        )}
        tell_async(:events, event.origin.id, {:auth, token})
        write_to(event.origin, :sys_message, message)
        Moongate.Say.pretty("#{Moongate.Say.origin(event.origin)} logged in.", :green)
        {:noreply, state}
      {:error, message} ->
        write_to(event.origin, :sys_message, message)
        Moongate.Say.pretty("Failed log in attempt from anonymous #{Moongate.Say.origin(event.origin)} connection.", :red)
        {:noreply, state}
      _ ->
        {:noreply, state}
    end
  end

  @doc """
    Create a new account with the given params if we're allowed.
  """
  def handle_cast({:register, event}, state) do
    {email, password} = event.params
    {status, _} = create_account(email, password)

    if status == :ok do
      IO.puts "Account for #{email} created."
      write_to(event.origin, :sys_message, "Your account has been created.")
    else
      write_to(event.origin, :sys_message, "Error creating account for #{email}.")
    end
    {:noreply, state}
  end

  @doc """
    Check whether a Moongate.SocketOrigin is authenticated.
  """
  def handle_call({:check_auth, origin}, _from, state) do
    has_id = Map.has_key?(state.tokens, String.to_atom(origin.id))
    origin_logged_in = Map.has_key?(origin.auth, :identity)

    if has_id and origin_logged_in do
      {email, identity} = Map.get(state.tokens, String.to_atom(origin.id))
      is_authenticated = identity == origin.auth.identity

      {:reply, {:ok, is_authenticated}, state}
    else
      {:reply, {:ok, false}, state}
    end
  end

  # Check if the requested login is correct.
  defp authenticate(email, password) do
    results = Moongate.Db.UserQueries.find_by_email(email)

    if length(results) == 0 do
      {:error, "The user account for that email doesn't exist."}
    else
      record = hd(results)
      {:ok, encrypted_pass} = :pbkdf2.pbkdf2(:sha256, password, record.password_salt, 4096)

      if :pbkdf2.to_hex(encrypted_pass) == record.password do
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
