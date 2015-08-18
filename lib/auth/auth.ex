defmodule Moongate.AuthToken do
  defstruct email: nil, identity: "anon"
end

# The Auth module manages login and new account creation.
defmodule Moongate.Auth do
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.SocketWriter

  def start_link do
    link(nil, "auth")
  end

  def handle_cast({:login, event}, _) do
    {email, password} = event.params
    auth_status = authenticate(email, password)

    case auth_status do
      {:ok, _} ->
        client_id = "client_" <> UUID.uuid4(:hex)
        token = %Moongate.AuthToken{email: email, identity: UUID.uuid4(:hex)}
        write_to(event.origin, %{
          cast: :set_token,
          namespace: :auth,
          value: "#{token.identity}"
        })
        tell_async(:events, event.origin.id, {:auth, token})
        Moongate.Say.pretty("#{client_id} logged in.", :green)
        {:noreply, nil}
      _ ->
        Moongate.Say.pretty("Failed log in attempt from anonymous #{Atom.to_string(event.origin.protocol)} connection.", :red)
        {:noreply, nil}
    end
  end

  @doc """
    Make a new account with the given params if we're allowed.
  """
  def handle_cast({:register, event}, _) do
    {email, password} = event.params
    {status, _} = create_account(email, password)

    if status == :ok do
      IO.puts "account created"
    else
      IO.puts "error creating account"
    end
    {:noreply, nil}
  end

  # Check if the requested login is correct.
  # TODO: Make secure.
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
