defmodule Db.Area do
  use Ecto.Model

  schema "areas" do
    field :height, :integer
    field :width, :integer
    field :chunk_height, :integer
    field :chunk_width, :integer

    field :attributes, {:array, :string}
    field :entity_ids, {:array, :integer}
    field :chunk_seeds, {:array, :string}
  end
end
