defmodule Moongate.Logger.Service do
  @colors %{
    down: :darkorange,
    error: :coral,
    info: :color189,
    fiber: :color110,
    up: :green,
    ring: :gold,
    session: :color128,
    socket: :color92,
    zone: :deepskyblue,
    status: :lightcyan,
    success: :springgreen,
    warning: :color239
  }
  @palettes %{
    amber: [:color239, :color166, :color214, :color221, :color94, :color227],
    cool: [:color21, :color27, :color33, :color39, :color45, :color51],
    grape: [:color92, :color98, :color104, :color110, :color116, :color122],
    hot: [:color196, :color202, :color208, :color214, :color220, :color226],
    ooze: [:color90, :color96, :color102, :color108, :color114, :color120],
    phosor: [:color239, :color22, :color28, :color34, :color40, :color46],
    shortcake: [:color199, :color205, :color211, :color217, :color223, :color229]
  }
  @reset_code :reset

  @doc """
  Logs a message to the console.
  """
  def log(:moongate_banner) do
    """

      █▀▄▀█ ███▄  ███▄     ▄     ▄▀  ██     ▄▄▄▄▀ ▄███▄  
      █ █ █ █   █ █   █     █  ▄▀    █ █ ▀▀▀ █    █▀   ▀ 
      █ ▄ █ █   █ █   █ ██   █ █ ▀▄  █▄▄█    █    ██▄▄   
      █   █ ▀████ ▀████ █ █  █ █   █ █  █   █     █▄   ▄▀
         █              █  █ █  ███     █  ▀      ▀███▀  
        ▀               █   █          
    """
    |> print_with_palette(:ooze)
    "Version #{Moongate.Core.version} (#{Moongate.Core.codename})"
    |> print_with_palette(:cool)
  end
  def log({{type, message}, :up}) do
    [color(type), message, @reset_code, " is ", color(:up), :bright, "UP", @reset_code]
    |> print
  end
  def log({{type, message}, :down}) do
    [color(type), message, @reset_code, " is ", color(:down), :bright, "DOWN", @reset_code]
    |> print
  end
  def log({type, message}) when is_map(message) do
    gutter_width =
      Enum.sort(message, fn {k1, _v1}, {k2, _v2} ->
        String.length("#{k1}") > String.length("#{k2}")
      end)
      |> List.first
      |> elem(0)
      |> Atom.to_string
      |> String.length
    spaces = Stream.repeatedly(fn -> " " end)

    Enum.flat_map(message, fn {key, value} ->
      blank = Enum.take(spaces, gutter_width)
      label = String.slice("#{key}#{blank}", 0, gutter_width)

      [
        color(type), :bright, "#{label} ",
        @reset_code, :color252, "#{value}",
        @reset_code, "\n"
      ]
    end)
    |> print
  end
  def log({type, message}) do
    [color(type), message, @reset_code]
    |> print
  end

  @doc """
  Prints a colorized string using one of the
  preset color palettes. If ANSI is not enabled
  for the current terminal session, the string
  will be printed normally.
  """
  def print_with_palette(message, palette_name) do
    case @palettes[palette_name] do
      palette when is_list(palette) ->
        format_with_palette(message, palette)
        |> print
      _ ->
        IO.puts message
    end
  end

  # Returns a color by key, falling back to
  # the predefined reset code.
  defp color(key) do
    @colors[key] || @reset_code
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

  # Print a list of ANSI codes.
  defp print(ansi_codes) do
    ansi_codes
    |> Bunt.ANSI.format
    |> IO.puts
  end

  def origin(o) do
    "(#{o.id})"
  end
end
