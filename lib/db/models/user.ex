defmodule Db.User do
  use Ecto.Model

  schema "users" do
    field :email, :string
    field :password, :string
    field :password_salt, :string
    field :password_confirmation, :string, virtual: true
    field :session_token, :string

    # Perform validations with Vex
    field :_vex, :any, virtual: true
    field :errors, :any, virtual: true

    timestamps
  end

  @required_fields ~w(email password password_salt session_token)
  @optional_fields ~w()
end
