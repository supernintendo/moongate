defmodule Macros.Packets do
  defmacro __using__(_) do
    quote do
      # Coerce a packet list into a map with keynames.
      defp expect_from(event, schema) do
        results = Enum.reduce(
          Enum.map(0..length(Tuple.to_list(schema)) - 1,
                  fn(i) -> Map.put(%{}, elem(schema, i), elem(event.contents, i)) end),
          fn(first, second) -> Map.merge(first, second) end)

        %{event | contents: results}
      end

      # Remove escape characters from a string, split it on whitespaces
      # and return a list with the contents.
      defp packet_to_list(string) do
        if String.valid?(string) do
          list = String.split(Regex.replace(~r/[\n\b\t\r]/, string, ""))

          if hd(list) == "begin" && List.last(list) == "end" do
            tl(list)
          else
            [:invalid_message]
          end
        else
          [:invalid_message]
        end
      end

      defp from_list(list, {port, protocol}, id) do
        from_list(list, {port, protocol, nil}, id)
      end

      # Parse a packet list into an events list.
      defp from_list(list, {port, protocol, ip}, id) do
        origin = %SocketOrigin{
          id: id,
          ip: ip,
          port: port,
          protocol: protocol
        }
        case length(list) do
          1 ->
            %ClientEvent{
              contents: hd(list),
              origin: origin
            }
          2 ->
            %ClientEvent{
              cast: String.to_atom(hd(tl(list))),
              to: String.to_atom(hd(list)),
              origin: origin
            }
          3 ->
            %ClientEvent{
              cast: String.to_atom(hd(tl(list))),
              contents: List.to_tuple(tl(tl(list))),
              to: String.to_atom(hd(list)),
              origin: origin
            }
          _ when length(list) > 3 ->
            %ClientEvent{
              cast: String.to_atom(hd(tl(list))),
              contents: List.to_tuple(tl(tl(list))),
              to: String.to_atom(hd(list)),
              origin: origin
            }
          _ ->
            %ClientEvent{
              error: :list_too_small,
              origin: origin
            }
        end
      end
    end
  end
end
