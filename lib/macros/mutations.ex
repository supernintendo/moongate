defmodule Moongate.Macros.Mutations do
  defmacro __using__(opts) do
    quote do
      if unquote(opts[:genserver] == true) do
        def mutations(event, state) do
          (for mut <- event.mutations do
            mutation(mut, event, state)
          end)
          |> Enum.filter(&(&1 != nil))
          |> Enum.into(state)
        end
      end

      @doc """
        Takes a map and a value and returns the same map
        with that value added to the end of its `mutations`
        list.
      """
      def mutate(map, value) do
        %{map | mutations: map.mutations ++ [value]}
      end
    end
  end
end
