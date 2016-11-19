defmodule Moongate.Packets do
  @moduledoc """
    Provides functions related to working with socket
    packets.
  """

  @operations %{
    void: 0x00,
    call: 0x01,
    info: 0x02,
    request: 0x03,
    respond: 0x04,
    join: 0x05,
    leave: 0x06,
    add: 0x07,
    remove: 0x08,
    set: 0x09,
    transform: 0x0A,
    ping: 0x0B,
    status: 0x0C
  }

  @doc """
    Takes a packet after it has been converted into
    a List and returns the byte size of all characters
    other than brackets.
  """
  def actual_size(parts) do
    parts
    |> without_brackets
    |> tl
    |> List.to_string
    |> byte_size
  end

  @doc """
    Takes a packet list and returns whether or
    not its first element is a number (i.e. the
    packet size).
  """
  def list_begins_with_number(parts) do
    Regex.match?(~r/^[0-9]*$/, hd(parts))
  end

  @doc """
    Takes a packet string and adds the delimiter
    around brackets to make it more suitable for
    breaking apart into a List.
  """
  def pad_brackets(string) do
    Regex.replace(~r/[\}]/, Regex.replace(~r/[\{]/, string, "·{·"), "·}·")
  end

  @doc """
    Make sense of a packet. This is the main packet
    pipeline, and follows the lifespan of a packet
    from when it is received to when it is dealt
    with.
  """
  def parse(string) do
    IO.inspect string

    string
    |> replace_whitespace
    |> pad_brackets
    |> turn_to_list
    |> validate
  end

  def operations, do: @operations

  @doc """
    Takes a string and returns the same string
    with whitespace removed.
  """
  def replace_whitespace(string) do
    Regex.replace(~r/[\n\b\t\r]/, string, "")
  end

  @doc """
    Takes a packet list after and converts the
    head of the list (defined packet size) to
    an integer for comparison with the actual
    value.
  """
  def reported_size(parts) do
    parts
    |> hd
    |> String.to_integer
  end

  @doc """
    Takes a string and splits it over a delimiter,
    returning a list with whitespace only elements
    removed.
  """
  def turn_to_list(string) do
    string
    |> String.split("·")
    |> Enum.filter(&(&1 != ""))
  end

  @doc """
    Make a series of checks on the packet to assure
    it is valid. If it is, return a successful
    response to indicate it is okay to use.
  """
  def validate(parts) do
    if list_begins_with_number(parts) do
      if reported_size(parts) == actual_size(parts) do
        {:ok, tl(without_brackets(parts))}
      else
        {:error, :bad_packet_length}
      end
    else
      {:error, :bad_packet}
    end
  end

  def whitelist(collection, list) do
    collection
    |> Enum.filter(fn ({key, _value}) ->
      list |> Enum.any?(&(&1 == key))
    end)
  end

  @doc """
    Takes a packet list and returns the same
    list without brackets.
  """
  def without_brackets(parts) do
    parts -- ["{", "}"]
  end
end
