defmodule Moongate.Logger.Service do
  @colors %{
    down: :darkorange,
    error: :coral,
    fiber: :blue,
    up: :green,
    ring: :mediumblue,
    session: :color128,
    socket: :color190,
    zone: :deepskyblue,
    status: :lightcyan,
    success: :springgreen,
    warning: :gold
  }

  def ansi(list, options) do
    if options[:timestamp] do
      [IO.ANSI.color(3, 3, 3) <> "#{Moongate.Core.formatted_time} " <> IO.ANSI.reset] ++ list
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

  def log(:up, {type, message}) do
    [color(type), message, :reset, " is ", color(:up), :bright, "UP", :reset]
    |> print
  end

  def log(:down, {type, message}) do
    [color(type), message, :reset, " is ", color(:down), :bright, "DOWN", :reset]
    |> print
  end

  defp color(key) do
    @colors[key] || :reset
  end

  defp print(chunks) do
    chunks
    |> Bunt.ANSI.format
    |> IO.puts
  end

  def pretty(string, modifier) do
    pretty(string, modifier, [])
  end

  def pretty(string, modifier, options) do
    if options[:suppress_timestamp] do
      [modifier, string]
      |> ansi
    else
      [modifier, string]
      |> ansi([timestamp: true])
    end
  end

  def origin(o) do
    "(#{o.id})"
  end
end
