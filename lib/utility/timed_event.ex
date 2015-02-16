defmodule TimedEvent do
  def start_link(target, message, interval) do
    tick(target, message, interval)
  end

  defp tick(target, message, interval) do
    tick(target, message, interval, 0)
  end

  defp tick(target, message, interval, current) do
    if current >= interval do
      tick(target, message, interval)
    else
      tick(target, message, interval, current + 1)
    end
  end
end