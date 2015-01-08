defmodule Db.Session do
  use Ecto.Model

  schema "sessions" do
    field :name, :string
    field :created_at, :datetime
    field :last_played, :datetime
    field :modifier_ids, {:array, :integer} 
    field :zone_ids, {:array, :integer}
  end
end
