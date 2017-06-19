defmodule Moongate.Logger do
  alias Moongate.{
    CoreConfig,
    CoreFirmware,
    CoreTypes,
    LoggerState
  }
  require Logger
  use GenServer

  @colors %{
    down: :darkorange,
    error: :color196,
    fiber: :color110,
    info: :color189,
    packet: :color230,
    ring: :gold,
    session: :color128,
    socket: :color33,
    success: :springgreen,
    up: :green,
    warning: :color214,
    zone: :color80
  }
  @gradients %{
    amber: [:color239, :color166, :color214, :color221, :color94, :color227],
    cool:  [:color21, :color27, :color33, :color39, :color45, :color51],
    grape: [:color92, :color98, :color104, :color110, :color116, :color122],
    hot:   [:color196, :color202, :color208, :color214, :color220, :color226],
    ooze:  [:color90, :color96, :color102, :color108, :color114, :color120],
    phosphor: [:color239, :color22, :color28, :color34, :color40, :color46],
    shortcake: [:color229, :color223, :color217, :color211, :color205, :color199]
  }
  @reset_code :reset

  def start_link(%CoreConfig{logger_mode: _logger_mode, log: _log} = config) do
    state =
      {config, %LoggerState{}}
      |> CoreTypes.cast!()

    GenServer.start_link(__MODULE__, state, [name: :logger])
  end

  def handle_cast({:log, _message}, %LoggerState{logger_mode: :none} = state) do
    {:noreply, state}
  end

  def handle_cast({:log, message}, %LoggerState{} = state) do
    log(message, state)

    {:noreply, state}
  end

  def handle_cast({:log, message, status}, %LoggerState{} = state) do
    log({message, status}, state)

    {:noreply, state}
  end

  defp log({:banner, {palette, contents}}, %LoggerState{} = state) do
    contents
    |> print_with_emphasis(palette, state)

    "Version #{CoreFirmware.version()} (#{CoreFirmware.codename()})"
    |> print_with_emphasis(:cool, state)
  end
  defp log({{type, message}, status}, %LoggerState{logger_mode: :console} = state) do
    case should_log?(type, state) do
      true ->
        [
          color(type), message, @reset_code, " is ",
          color(status), :bright, String.upcase("#{status}"),
          @reset_code
        ]
        |> print()
      _ ->
        nil
    end
  end
  defp log({type, %{__struct__: _struct} = message}, %LoggerState{logger_mode: :console} = state) do
    log({type, Map.delete(message, :__struct__)}, state)
  end
  defp log({type, message}, %LoggerState{logger_mode: :console} = state) when is_map(message) do
    case should_log?(type, state) do
      true ->
        key =
          Enum.sort(message, fn {k1, _v1}, {k2, _v2} ->
            String.length("#{k1}") > String.length("#{k2}")
          end)
          |> List.first()
          |> elem(0)

        gutter_width = String.length("#{key}")
        spaces = Stream.repeatedly(fn -> " " end)

        ["\n"] ++ Enum.flat_map(message, fn {key, value} ->
          blank = Enum.take(spaces, gutter_width)
          label = String.slice("#{key}#{blank}", 0, gutter_width)
          [
            color(type), :bright, "#{label} ",
            @reset_code, CoreTypes.cast({value, String}), "\n"
          ]
        end)
        |> print()
      _ ->
        nil
    end
  end
  defp log({type, message}, %LoggerState{logger_mode: :console} = state) do
    case should_log?(type, state) do
      true ->
        [color(type), message, @reset_code]
        |> print()
      _ ->
        nil
    end
  end
  defp log({{type, message}, status}, %LoggerState{} = state) do
    case should_log?(type, state) do
      true ->
        prefix = String.upcase("#{status}")
        logger({type, "#{prefix}: #{message}"})
      _ -> nil
    end
  end
  defp log({type, message}, %LoggerState{} = state) do
    case should_log?(type, state) do
      true -> logger({type, "#{inspect message}"})
      _ -> nil
    end
  end

  # Returns a color by key, falling back to
  # the predefined reset code.
  defp color(key) do
    @colors[key] || @reset_code
  end

  defp logger({:error, message}) do
    Logger.error(message)
  end
  defp logger({:warning, message}) do
    Logger.warn(message)
  end
  defp logger({_type, message}) do
    Logger.info(message)
  end

  # Print a list of ANSI codes.
  defp print(ansi_codes) do
    ansi_codes
    |> Bunt.ANSI.format()
    |> IO.puts()
  end

  defp print_with_emphasis(message, gradient_name, %{logger_mode: :console}) do
    case @gradients[gradient_name] do
      palette when is_list(palette) ->
        format_with_palette(message, palette)
        |> print()
      _ ->
        IO.puts(message)
    end
  end
  defp print_with_emphasis(message, _gradient_name, _state) do
    Logger.info(~s(
      ============
       #{message}
      ============
    ))
  end

  defp should_log?(type, %LoggerState{logger_mode: logger_mode, log: log}) do
    Map.get(log, logger_mode, %{})
    |> Map.get(type, false)
  end

  # Returns a list of ANSI codes such that color
  # codes within the provided color palette are
  # evenly distributed amongst characters within
  # the string.
  defp format_with_palette(message, palette) do
    palette_length = length(palette)
    message_length = String.length(message)
    weight = round(message_length / palette_length)

    String.codepoints(message)
    |> Enum.reduce({[], 0, palette}, fn char, {chunks, counter, current_palette} ->
      current_color = List.first(current_palette) || @reset_code
      cond do
        rem(counter, weight) == weight - 1 ->
          [_palette_head | palette_tail] = current_palette
          {chunks ++ [current_color, char], counter + 1, palette_tail}
        true ->
          {chunks ++ [current_color, char], counter + 1, current_palette}
      end
    end)
    |> elem(0)
  end
end
