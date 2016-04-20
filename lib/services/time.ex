defmodule Moongate.Time do
  @moduledoc """
    Provides functions related to time.
  """
  use Timex

  def current_ms do
    :msecs
    |> Time.now
    |> round
  end

  def now_formatted do
    {:ok, date} = DateFormat.format(Date.local, "%b %d - %I:%0M:%0S %p", :strftime)

    date
  end
end
