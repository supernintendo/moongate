defmodule Moongate.Say do
  @moduledoc """
    Provides functions related to console output.
  """

  def ansi(list, options) do
    modified = list

    if options[:timestamp] do
      [:bright, "#{Moongate.Time.now_formatted} " <> IO.ANSI.reset] ++ list
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

  @doc """
    A greeting message, output when the server is started.
  """
  def greeting do
    IO.puts ""
    pretty(" )\/)  _   _   _   _   _  _)_ _", :blue, [suppress_timestamp: true])
    pretty("(  ( (_) (_) ) ) (_( (_( (_ )_)", :blue, [suppress_timestamp: true])
    pretty("                   _)      (_", :blue, [suppress_timestamp: true])
    IO.puts ""

    [:inverse,
     "v#{Moongate.Mixfile.project[:version]}"
     <> IO.ANSI.reset
     <> " #{Moongate.Mixfile.project[:codename]}"
    ]
    |> ansi

    ["Your current world is: "] ++ [:magenta, "#{Moongate.Worlds.get_world}"]
    |> ansi

    IO.puts ""
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
    if o.auth != nil and o.auth.email != nil do
      o.auth.email
    else
      "Anonymous (#{o.id})"
    end
  end
end
