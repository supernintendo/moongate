defmodule Db.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    [
       """
       CREATE TABLE IF NOT EXISTS users (
         id                      serial          PRIMARY KEY,
         email                   varchar(255)    NOT NULL UNIQUE,
         password                varchar(255)    NOT NULL,
         salt                    varchar(32)     NOT NULL,
         created_at              timestamp       WITH TIME ZONE NOT NULL DEFAULT NOW(),
         last_login              timestamp       WITH TIME ZONE NOT NULL DEFAULT NOW()
       );
       """
    ]
  end

  def down do
    "DROP TABLE users;"
  end
end
