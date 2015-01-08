defmodule Db.UserQueries do
  import Ecto.Query

  alias Db.Repo, as: Repo
  alias Db.User, as: User

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
    # TODO: Better crypto.
    salt = UUID.uuid4(:hex)
    # {:ok, encrypted_pass} = :pbkdf2.pbkdf2(:sha256, params[:password], salt, 4096)

    [
        email: params[:email],
        password: params[:password],
        salt: salt,
        created_at: Ecto.DateTime.utc,
        last_login: Ecto.DateTime.utc
    ]
  end
end
