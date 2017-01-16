defmodule Test.Deed.TestDeed do
  use Moongate.DSL, :deed

  attributes %{
    test_attr: :float
  }

  def init(entity) do
    entity
  end

  def call(entity, {value}) do
    entity
    |> set(%{test_attr: value})
  end
end
