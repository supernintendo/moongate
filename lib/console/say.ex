defmodule Say do
  @doc """
    A greeting message, output when the server is started.
  """
  def greeting do
    pretty("               ____....
           a≈≈≈≈≈~::::::::,..   .                 |
       a≈≈≈≈≈≈P;:::::::::::::,.   .   .   .     --*--
    a≈≈≈≈≈≈≈≈::::::::::::::::::,.  `              |        .
   ≈≈≈≈≈≈≈≈P::::::::::::*::::::::.. .   .                         .
  ≈≈≈≈≈≈≈≈P::::::::::::::::::.::::;..
 ≈≈≈≈≈ ≈≈P::::::::::::::::::::::.:;.;..       m o o n
.≈≈≈≈ O ≈≈:::::*:::::::::::::::.::;;;.        ", :blue)
    pretty("≈≈≈≈≈≈ ≈≈≈≈ ::::::::::::::.::::::.:::::               g a t e
≈≈≈≈≈≈≈≈@≈≈≈,:::::::::::::::::::::::::;
≈≈≈≈≈≈≈≈≈~~~:::::::::::::::*:::.::::::;       /            .        .", :magenta)
    pretty(" ≈≈≈≈≈ ≈≈:::::::-:::::::::::::::::::::;      /       .
  ≈≈≈≈a__ay:::::::::::::::::::::::::::.     *
   ≈≈≈≈≈≈≈≈;:::::::::::::::::::::::::                      .
    ≈≈≈≈≈≈≈≈a:::::::::::::::::::::::                     .      *         .
      ≈≈≈≈≈≈≈≈.:::::::::*;:::::::::             .                        . .
       `d≈≈≈≈≈≈a.::::::::::::::::   .                                 .  .
          `~9≈≈≈≈≈.:::::::::::           .               .            .", :red)
    pretty("Game server version #{Moongate.Mixfile.project[:version]}", :underline)
  end

  @doc """
    Format and output a colorized ANSI string.
  """
  def pretty(string, modifier) do
    IO.puts(
      IO.chardata_to_string(
        IO.ANSI.format_fragment(
          [modifier, string <> IO.ANSI.reset], true)))
  end
end
