defmodule Moongate.Events do
  def scope_message(message) do
    cond do
      List.first(message) == nil ->
        {:none}
      is_uppercase(message) ->
        message |> to_pool_or_deed
      true ->
        {:stage, message}
    end
  end

  def delimited_values(message) do
    message
    |> List.first
    |> String.split(".")
  end

  def first_character(message) do
    message
    |> List.first
    |> String.codepoints
    |> hd
  end

  def is_uppercase(message) do
    Regex.match?(~r/^[A-Z]$/, first_character(message))
  end

  def to_pool_or_deed(message) do
    cond do
      message |> delimited_values |> length == 2 ->
        {:deed, message}
      true ->
        {:pool, message}
    end
  end
end
