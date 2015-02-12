# The Auth module manages login and new account creation.
defmodule Auth do
  use GenServer
  use Mixins.SocketWriter
  use Mixins.Store

  def start_link do
    state = %{}
    GenServer.start_link(__MODULE__, state, [name: :auth])
  end

  def handle_cast({:login, event, from}, state) do
    case authenticate(event.contents) do
      {:ok, message} ->
        client_id = "client_" <> UUID.uuid4(:hex)
        token = %AuthToken{email: event.contents[:email], source: event.origin}
        state_mod = Map.put(state, String.to_atom(client_id), token)
        write_to(event.origin, %{
          cast: :set_token,
          namespace: :auth,
          value: "#{token.identity}"
        })
        GenServer.cast(from, {:auth, token.identity})
        Say.pretty("#{client_id} logged in.", :green)
        {:noreply, state_mod}
      {_, message} ->
        Say.pretty("Failed log in attempt from anonymous #{Port.info(event.origin)[:name]} connection.", :red)
        {:noreply, state}
    end
  end
  
  @doc """
    Make a new account with the given params if we're allowed.
  """
  def handle_cast({:register, event}, state) do
    {status, response} = create_account(event.contents)

    if status == :ok do
      IO.puts "account created"
    else
      IO.puts "error creating account"
    end
    {:noreply, state}
  end

  # Check if the requested login is correct.
  # TODO: Make secure.
  defp authenticate(params) do
    results = Db.UserQueries.find_by_email(params[:email])

    if length(results) == 0 do
      {:error, "bad_email"}
    else
      if hd(results).password == params[:password] do
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
