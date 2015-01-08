defmodule Db.User do
  use Ecto.Model

  schema "users" do
    field :email, :string
    field :password, :binary
    field :salt, :string
    field :created_at, :datetime
    field :last_login, :datetime
  end
end
