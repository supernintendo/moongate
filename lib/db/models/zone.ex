defmodule Db.Zone do
  use Ecto.Model

  schema "zones" do
    field :name, :string
    field :created_at, :datetime
    field :last_visited, :datetime
    field :area_ids, {:array, :integer}
    field :attributes, {:array, :string}
  end
end
