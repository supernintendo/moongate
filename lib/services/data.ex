defmodule Moongate.Data do
  @doc """
    Remove any special attributes from a pool member's
    keyword list, allowing it to be compared to items
    within a pool's members list.
  """
  def condense_pool_member(member) do
    member |> Keyword.delete(:__moongate_pool)
  end

  def into(original) do
    {original, fn
      map, {:cont, {k, v}} ->
        :maps.put(k, v, map)
      map, :done -> map
    _, :halt -> :ok
    end}
  end

  def pool_member_attr(member, key) do
    mutations = elem(member[key], 1)

    if length(mutations) > 0 do
      mod = Enum.reduce(mutations, 0, fn(mutation, acc) ->
        acc + mutation.by * (Moongate.Time.current_ms - mutation.time_started)
      end)
      elem(member[key], 0) + mod
    else
      elem(member[key], 0)
    end
  end
end
