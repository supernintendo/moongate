defmodule Moongate.Time do
  use Timex

  # Return a map containing the difference between two UNIX
  # timestamps.
  def diff(from, to) do
    time = Date.convert(to, :secs) - Date.convert(from, :secs)

    %{
      days: div(time, 86400),
      hours: div(rem(time, 86400), 3600),
      minutes: div(rem(rem(time, 86400), 3600), 60),
      seconds: rem(rem(rem(time, 86400), 3600), 60),
      ms: rem(rem(rem(rem(time, 86400), 3600), 60), 1000)
    }
  end
end