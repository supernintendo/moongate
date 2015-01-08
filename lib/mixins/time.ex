defmodule Mixins.Time do
  defmacro __using__(opts) do
    quote do
      # Return a map containing the difference between two UNIX
      # timestamps.
      defp diff(from, to) do  
        time = Date.convert(to, :secs) - Date.convert(from, :secs)

        %{
          days: div(time, 86400),
          hours: div(rem(time, 86400), 3600),
          minutes: div(rem(rem(time, 86400), 3600), 60),
          seconds: rem(rem(rem(time, 86400), 3600), 60)
        }
      end
    end
  end
end
