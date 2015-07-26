defmodule Macros.Packets do
  defmacro __using__(_) do
    quote do
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
