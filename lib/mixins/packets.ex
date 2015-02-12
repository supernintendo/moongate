defmodule Mixins.Packets do
  defmacro __using__(opts) do
    quote do
      # Remove escape characters from a string, split it on whitespaces
      # and return a list with the contents.
      defp packet_to_list(string) do
        if String.valid?(string) do
          String.split(Regex.replace(~r/[\n\b\t\r]/, string, ""))
        else
          [:invalid_message]
        end
      end

      # Parse a packet list into an events list.
      defp from_list(list, socket, id) do
        case length(list) do
          1 ->
            %ClientEvent{
              contents: hd(list),
              origin: %SocketOrigin{
                id: id,
                port: socket
              }
            }
          2 ->
            %ClientEvent{
              cast: String.to_atom(hd(tl(list))),
              to: String.to_atom(hd(list)),
              origin: %SocketOrigin{
                id: id,
                port: socket
              }
            }
          3 ->
            %ClientEvent{
              cast: String.to_atom(hd(tl(list))),
              contents: List.to_tuple(tl(tl(list))),
              to: String.to_atom(hd(list)),
              origin: %SocketOrigin{
                id: id,
                port: socket
              }
            }
          _ when length(list) > 3 ->
            %ClientEvent{
              cast: String.to_atom(hd(tl(list))),
              contents: List.to_tuple(tl(tl(list))),
              to: String.to_atom(hd(list)),
              origin: %SocketOrigin{
                id: id,
                port: socket
              }
            }
          _ ->
            %ClientEvent{
              error: :list_too_small,
              origin: %SocketOrigin{
                id: id,
                port: socket
              }
            }
        end
      end
    end
  end
end
