defmodule Moongate.Db.UserQueries do
  @capital_letters    ?A..?Z |> Enum.map(&String.Chars.to_string([&1]))
  @lowercase_letters  ?a..?z |> Enum.map(&String.Chars.to_string([&1]))
  @numbers            0..9 |> Enum.map fn (n) -> "#{n}" end

  import Ecto.Query

  alias Moongate.Db.Repo, as: Repo
  alias Moongate.Db.User, as: User

  def create(params) do
   if (length(find_by_email(params[:email])) == 0) do
     user = struct(User, generate_user(params))
     {:ok, Repo.insert(user)}
   else
     {:error, "User with email #{params[:email]} exists."}
   end
  end

  def delete(id) do
    user = Repo.get(User, id)
    Repo.delete(user)
  end

  def find_by_email(email) do
    query = from u in User,
          where: u.email == ^email,
          select: u

    Repo.all(query)
  end

  def generate_user(params) do
    salt = generate_salt
    {:ok, encrypted_pass} = :pbkdf2.pbkdf2(:sha256, params[:password], salt, 4096)
    password = :pbkdf2.to_hex(encrypted_pass)

    [
      email: params[:email],
      password: password,
      password_salt: salt,
      created_at: Ecto.DateTime.utc,
      last_login: Ecto.DateTime.utc
    ]
  end

  def generate_salt do
    # Get 12 random bytes and cast them as 3 32-bit ints
    <<a :: size(32), b :: size(32), c :: size(32) >> = :crypto.rand_bytes(12)

    # Use random ints for seeding
    :random.seed({a,b,c})

    Enum.shuffle(salt_characters) |> Enum.slice(0..15) |> Enum.join("")
  end

  defp salt_characters do
    @capital_letters ++ @lowercase_letters ++ @numbers
  end
end
