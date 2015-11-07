defmodule Moongate.Time do
  use Timex

  def current_ms do
    round(Time.now(:msecs))
  end
 
  def now_formatted do
    {:ok, date} = DateFormat.format(Date.local, "%b %d - %I:%0M:%0S %p", :strftime)
    date
  end
end
