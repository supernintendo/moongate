defmodule Moongate.Time do
  @moduledoc """
    Provides functions related to time.
  """
  use Timex

  def current_ms do
    Time.now(:milliseconds) |> round
  end

  def now_formatted do
    {:ok, date} = Timex.format(DateTime.today, "{ISO:Extended}")

    date
  end
end
