defmodule Moongate.Logger.Service do
  @colors %{
    down: :darkorange,
    error: :coral,
    fiber: :blue,
    up: :green,
    pool: :mediumblue,
    session: :color128,
    socket: :color190,
    stage: :deepskyblue,
    status: :lightcyan,
    success: :springgreen,
    warning: :gold
  }

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
end
