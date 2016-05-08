defmodule Moongate.Time do
  @moduledoc """
    Provides functions related to time.
  """
  use Timex

  @months {
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  }

  def current_ms do
    Time.now(:milliseconds) |> round
  end

  def now_formatted do
    {{year, month, day}, {hour, min, _sec}} = :calendar.local_time()

    "#{@months |> elem(month - 1)} #{day}, #{year} · #{hour}:#{min} "
  end
end
