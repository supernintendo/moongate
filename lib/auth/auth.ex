defmodule Moongate.AuthSessions do
  defstruct tokens: %{}
end

defmodule Moongate.AuthToken do
  defstruct email: nil, identity: "anon"
end

# The Auth module manages login and new account creation.
defmodule Moongate.Auth do
  use GenServer
  use Moongate.Macros.Processes

  def start_link do
    link(%Moongate.AuthSessions{}, "auth")
  end

  @doc """
    Attempt to login with the provided credentials.
  """
  def handle_cast({:login, event}, state) do
    {email, password} = event.params
    auth_status = authenticate(email, password)

    case auth_status do
      {:ok, _} ->
        token = %Moongate.AuthToken{email: email, identity: UUID.uuid4(:hex)}
        state = %{state | tokens: Map.put(
          state.tokens,
          String.to_atom(event.origin.id),
          token.identity
        )}
        tell_async(:events, event.origin.id, {:auth, token})
        Moongate.Say.pretty("#{Moongate.Say.origin(event.origin)} logged in.", :green)
        {:noreply, state}
      _ ->
        Moongate.Say.pretty("Failed log in attempt from anonymous #{Moongate.Say.origin(event.origin)} connection.", :red)
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
      IO.puts "account created"
    else
      IO.puts "error creating account"
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
      id_authenticated = Map.get(state.tokens, String.to_atom(origin.id)) == origin.auth.identity

      {:reply, {:ok, id_authenticated}, state}
    else
      {:reply, {:ok, false}, state}
    end
  end

  # Check if the requested login is correct.
  defp authenticate(email, password) do
    results = Moongate.Db.UserQueries.find_by_email(email)

    if length(results) == 0 do
      {:error, "bad_email"}
    else
      record = hd(results)
      {:ok, encrypted_pass} = :pbkdf2.pbkdf2(:sha256, password, record.password_salt, 4096)

      if :pbkdf2.to_hex(encrypted_pass) == record.password do
        {:ok, "login_success"}
      else
        {:error, "bad_password"}
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
