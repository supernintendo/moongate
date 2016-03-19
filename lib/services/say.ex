defmodule Moongate.Say do
  @doc """
    A greeting message, output when the server is started.
  """
  def greeting do
    IO.puts ""
    pretty(" )\/)  _   _   _   _   _  _)_ _", :blue, [suppress_timestamp: true])
    pretty("(  ( (_) (_) ) ) (_( (_( (_ )_)", :blue, [suppress_timestamp: true])
    pretty("                   _)      (_", :blue, [suppress_timestamp: true])
    IO.puts ""
    IO.puts(
      IO.chardata_to_string(["☪ "] ++
        IO.ANSI.format_fragment(
          [:inverse, "v#{Moongate.Mixfile.project[:version]}" <> IO.ANSI.reset <> " #{Moongate.Mixfile.project[:codename]}"], true)))
    IO.puts(
      IO.chardata_to_string(["Your current world is: "] ++
        IO.ANSI.format_fragment(
          [:magenta, "#{Moongate.Worlds.get_world}" <> IO.ANSI.reset], true)))

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
      timestamp = [""]
    else
      if modifier == :red do
        timestamp_modifier = :red
      else
        timestamp_modifier = :bright
      end
      timestamp = IO.ANSI.format_fragment([timestamp_modifier, "#{Moongate.Time.now_formatted}" <> IO.ANSI.reset], true) ++
                  IO.ANSI.format_fragment([:black, " ∙ ", IO.ANSI.reset])
    end

    IO.puts(
      IO.chardata_to_string(timestamp ++
        IO.ANSI.format_fragment(
          [modifier, string <> IO.ANSI.reset], true)))
  end

  @doc """
    Given a Moongate.SocketOrigin, return the appropriate
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
