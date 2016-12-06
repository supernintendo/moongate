defmodule Moongate.Packets.Metadata do
  defmacro __using__(_opts) do
    operations =
      File.read!("priv/metadata/operations")
      |> String.split("\n")
      |> Enum.map(&String.downcase/1)

    operation_map =
      operations
      |> Enum.map_reduce(0, fn key, acc ->
        {{String.to_atom(key), acc}, acc + 1}
      end)
      |> elem(0)

    quote do
      def packet_operations do
        %{
          by_key: unquote(operation_map),
          by_index: unquote(operations)
        }
      end
    end
  end
end
