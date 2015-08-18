defmodule Moongate.Say do
  @doc """
    A greeting message, output when the server is started.
  """
  def greeting do
    pretty("
       _..._
     .' .::::.
    :  ::::::::  moongate", :blue)
   pretty("    :  ::::::::   v#{Moongate.Mixfile.project[:version]}
    `. '::::::'
      `-.::''
    ", :magenta)
  end

  @doc """
    Format and output a colorized ANSI string.
  """
  def pretty(string, modifier) do
    IO.puts(
      IO.chardata_to_string(
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
