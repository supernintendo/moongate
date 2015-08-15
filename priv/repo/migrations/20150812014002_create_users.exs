defmodule Db.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :serial, primary_key: true
      add :email, :string, null: false
      add :password, :string, null: false
      add :password_salt, :string, null: false
      add :session_token, :string
      timestamps
    end

    create index(:users, [:id], unique: true)
    create index(:users, ["lower(email)"], unique: true)
    create index(:users, ["lower(session_token)"], unique: true)
  end

  def down do
    drop table(:users)
  end
end
