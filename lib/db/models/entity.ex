defmodule Db.Entity do
  use Ecto.Model

  schema "entity" do
    field :index, :string
    field :attributes, {:array, :string}
  end
end
