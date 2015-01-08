defmodule Db.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    parse_url "ecto://moongate:moongate@localhost/moongate"
  end

  def priv do
    app_dir(:moongate, "priv/repo")
  end
end
