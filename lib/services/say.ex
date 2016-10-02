defmodule Moongate.Say do
  @moduledoc """
    Provides functions related to console output.
  """

  def ansi(list, options) do
    if options[:timestamp] do
      [IO.ANSI.color(3, 3, 3) <> "#{Moongate.Time.now_formatted} " <> IO.ANSI.reset] ++ list
      |> ansi
    else
      ansi(list)
    end
  end

  def ansi(list) do
    list ++ [IO.ANSI.reset]
    |> IO.ANSI.format_fragment(true)
    |> IO.chardata_to_string
    |> IO.puts
  end

  def pretty(string, modifier) do
    pretty(string, modifier, [])
  end

  @doc """
    Format and output a colorized ANSI string.
  """
  def pretty(string, modifier, options) do
    if options[:suppress_timestamp] do
      [modifier, string]
      |> ansi
    else
      [modifier, string]
      |> ansi([timestamp: true])
    end
  end

  @doc """
    Given a Moongate.Origin, return the appropriate
    string to use to represent that origin.
  """
  def origin(o) do
    "(#{o.id})"
  end
end
