defmodule Moongate.Packets do
  @doc """
    Validate and parse an incoming packet.
  """
  def parse(string) do
    parsed_string = Regex.replace(~r/[\n\b\t\r]/, string, "")
    parsed_string = Regex.replace(~r/[\{]/, parsed_string, "·{·")
    parsed_string = Regex.replace(~r/[\}]/, parsed_string, "·}·")

    list = String.split(parsed_string, "·") |> Enum.filter(&(&1 != ""))
    inner = list -- ["{", "}"]

    if inner != [] and Regex.match?(~r/^[0-9]*$/, hd(list)) do
      # Make sure the packet length looks OK.
      expected_length = String.to_integer(hd(list))
      actual_length = byte_size(List.to_string(tl(inner)))

      if expected_length == actual_length do
        {:ok, tl(inner)}
      else
        {:error, :bad_packet_length}
      end
    else
      {:error, :bad_packet}
    end
  end

  @doc """
    This function takes a Moongate.SyncEvent which contains a list
    of keys and a list of lists containing values mapped to those
    keys. It generates a string representing these keys and the
    members of the collection.
  """
  def sync(message) do
    keys = List.to_string(Enum.map(tl(message.keys), &(Atom.to_string(&1) <> "¦")))
    keys_string = String.rstrip(keys, ?¦)
    values = List.to_string(Enum.map(message.values, fn(value_set) ->
      String.rstrip(List.to_string(Enum.map(value_set, &("#{&1}¦"))), ?¦) <> "„"
    end))
    values_string = String.rstrip(values, ?„)

    "#{keys_string}:#{values_string}"
  end
end
