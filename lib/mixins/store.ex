# Some methods for helping manipulate state within lists.
defmodule Mixins.Store do
  defmacro __using__(_) do
    quote do
      # Return map with one of its lists updated to contain a new item.
      defp add_to(map, key_of_list, item) do
        Map.merge(map, Map.put(%{},
          key_of_list,
        Map.get(map, key_of_list) ++ [item]))
      end

      # Given partial information, check a list in the map to see
      # if an item matches on any attributes in the conditions list.
      defp another_matches(map, key_of_list, conditions) do
        results =
          Enum.map(conditions, fn(condition) ->
            Enum.any?(Map.get(map, key_of_list), fn(item) ->
              Map.get(item, hd(condition)) == hd(tl(condition))
            end)
          end)
        Enum.any?(results, fn(result) -> result end)
      end

      # Return the map with one of its lists updated to exclude an item.
      defp drop_from(map, key_of_list, to_drop) do
        Map.merge(map, Map.put(%{},
          key_of_list,
            Enum.filter(Map.get(map, key_of_list), fn(item) ->
          item != to_drop end)))
      end

      # Set key value in a state map.
      defp set_in(map, key_of_map, key_of_attribute, value) do
        {:ok, prior} = Map.fetch(map, key_of_map)
        updated = Map.merge(prior, Map.put(%{}, key_of_attribute, value))
        Map.put(map, key_of_map, updated)
      end
    end
  end
end
