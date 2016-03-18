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
end
