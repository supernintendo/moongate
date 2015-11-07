defmodule Moongate.Data do
  @doc """
    Remove any special attributes from a pool member's
    keyword list, allowing it to be compared to items
    within a pool's members list.
  """
  def condense_pool_member(member) do
    member |> Keyword.delete(:__moongate__parent)
  end
end
