defmodule AuthToken do
  defstruct email: nil,
            identity: UUID.uuid4(:hex),
            source: nil
end

# The Auth module manages login and new account creation.
defmodule Auth do
  use Macros.SocketWriter
  use Macros.Store
  use Macros.Translator

  def start_link do
    link(nil, "auth")
  end

  def handle_cast({:login, event, from}, state) do
    auth_status = authenticate(event.contents)

    case auth_status do
      {:ok, _} ->
        client_id = "client_" <> UUID.uuid4(:hex)
        token = %AuthToken{email: event.contents[:email], source: event.origin}
        state_mod = Map.put(state, String.to_atom(client_id), token)
        write_to(event.origin, %{
          cast: :set_token,
          namespace: :auth,
          value: "#{token.identity}"
        })
        tell_pid_async(from, {:auth, token.identity})
        Say.pretty("#{client_id} logged in.", :green)
        {:noreply, state_mod}
      _ ->
        Say.pretty("Failed log in attempt from anonymous #{Atom.to_string(event.origin.protocol)} connection.", :red)
        {:noreply, state}
    end
  end

  @doc """
    Make a new account with the given params if we're allowed.
  """
  def handle_cast({:register, event}, state) do
    {status, _} = create_account(event.contents)

    if status == :ok do
      IO.puts "account created"
    else
      IO.puts "error creating account"
    end
    {:noreply, state}
  end

  def handle_call({:no_auth, value}, _from, state) do
    updated = Map.put(state, :no_auth, value)

    {:reply, nil, updated}
  end

  # Check if the requested login is correct.
  # TODO: Make secure.
  defp authenticate(params) do
    results = Db.UserQueries.find_by_email(params[:email])

    if length(results) == 0 do
      {:error, "bad_email"}
    else
      record = hd(results)
      {:ok, encrypted_pass} = :pbkdf2.pbkdf2(:sha256, params[:password], record.password_salt, 4096)

      if :pbkdf2.to_hex(encrypted_pass) == record.password do
        {:ok, "login_success"}
      else
        {:error, "bad_password"}
      end
    end
  end

  # Attempt to create an account with the given params.
  defp create_account(params) do
    Db.UserQueries.create([
      email: params[:email],
      password: params[:password]
    ])
  end
end
