defmodule Db.Repo.Migrations.CreateAreas do
  use Ecto.Migration

  def up do
    [
       """
       CREATE TABLE IF NOT EXISTS areas (
         id                      serial          PRIMARY KEY,
         height                  integer         NOT NULL,
         width                   integer         NOT NULL,
         chunk_height            integer         NOT NULL,
         chunk_width             integer         NOT NULL,

         attributes              text[]          NOT NULL,
         entity_ids              integer[]       NOT NULL,
         chunk_seeds             text[]          NOT NULL
       );
       """
    ]
  end

  def down do
    "DROP TABLE areas;"
  end
end
