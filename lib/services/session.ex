defmodule Moongate.Session.Service do
  @moduledoc """
    Provides functions related to working with event
    processes.
  """
  @whitelist ["auth"]

  @doc """
    Determine the best category of target process for
    an incoming message. This is where a message is
    determined to pertain to a deed, ring or zone based
    on its structure. For messages that don't conform to
    an indicative structure but do define a specific
    target, the target must be within @whitelist for
    the message to proceed. If this is not the case,
    the message is treated as if it were empty.
  """
  def scope_message(message) do
    cond do
      List.first(message) == nil ->
        {:none}
      is_uppercase(message) ->
        message |> to_ring_or_deed
      ":" == message |> hd |> String.codepoints |> hd ->
        if whitelisted(hd(message)) do
          {:tree, [String.lstrip(hd(message), ?:)] ++ tl(message)}
        else
          {:none}
        end
      true ->
        {:zone, message}
    end
  end

  @doc """
    Take a packet message list and split its first value
    by periods, to return a list representing the message
    target.
  """
  def delimited_values(message) do
    message
    |> List.first
    |> String.split(".")
  end

  @doc """
    Return the first character of the first element
    within a list.
  """
  def first_character(message) do
    message
    |> List.first
    |> String.codepoints
    |> hd
  end

  @doc """
    Return whether the first term of a packet message
    list is capitalized.
  """
  def is_uppercase(message) do
    Regex.match?(~r/^[A-Z]$/, first_character(message))
  end

  @doc """
    Return whether a message should target a deed or
    a ring based on how the target defined in the
    message is formatted.
  """
  def to_ring_or_deed(message) do
    cond do
      message |> delimited_values |> length == 2 ->
        {:deed, message}
      true ->
        {:ring, message}
    end
  end

  @doc """
    Check if the target defined in a message is
    within the @whitelist module attribute.
  """
  def whitelisted(message) do
    @whitelist
    |> Enum.any?(fn(name) ->
      name == String.lstrip(message, ?:)
    end)
  end
end
