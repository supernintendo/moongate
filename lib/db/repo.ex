defmodule Moongate.Repo do
  @moduledoc """
    This is the Ecto Repo for Moongate.
  """
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres, otp_app: :moongate
end
