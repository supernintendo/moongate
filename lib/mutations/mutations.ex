defmodule Moongate.Mutations do
  defmacro __using__(opts) do
    quote do
      if unquote(opts[:genserver] == true) do
        def handle_call({:mutations, event}, _from, state) do
          state = event |> mutations(state)

          {:reply, :ok, state}
        end

        def mutations(event, state) do
          (for mut <- event.__moongate_mutations do
            apply(Module.safe_concat([state.__struct__, Mutations]), :mutation, [mut, event, state])
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
        %{map | __moongate_mutations: map.__moongate_mutations ++ [value]}
      end
    end
  end

  def into(original) do
    {original, fn
      map, {:cont, {k, v}} ->
        :maps.put(k, v, map)
      map, :done -> map
    _, :halt -> :ok
    end}
  end
end
