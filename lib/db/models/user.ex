defmodule Moongate.Db.User do
  use Ecto.Model

  schema "users" do
    field :email, :string
    field :password, :string
    field :password_salt, :string
    field :password_confirmation, :string, virtual: true
    field :session_token, :string

    timestamps
  end

  @required_fields ~w(email password password_salt session_token)
  @optional_fields ~w()
end
