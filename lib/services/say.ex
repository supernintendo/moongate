defmodule Moongate.Say do
  @doc """
    A greeting message, output when the server is started.
  """
  def greeting do
    pretty("
       _..._
     .' .::::.
    :  ::::::::  moongate", :blue, [suppress_timestamp: true])
   pretty("    :  ::::::::   v#{Moongate.Mixfile.project[:version]}
    `. '::::::'
      `-.::''
    ", :magenta, [suppress_timestamp: true])
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
        timestamp_modifier = :red_background
      else
        timestamp_modifier = :black_background
      end
      timestamp = IO.ANSI.format_fragment([timestamp_modifier, "#{Moongate.Time.now_formatted}" <> IO.ANSI.reset], true) ++
                  IO.ANSI.format_fragment([:black, " ∙ ", IO.ANSI.reset])
    end

    IO.puts(
      IO.chardata_to_string(timestamp ++
        IO.ANSI.format_fragment(
          [modifier, string <> IO.ANSI.reset], true)))
  end

  def origin(o) do
    if o.auth != nil and o.auth.email != nil do
      o.auth.email
    else
      o.id
    end
  end
end
