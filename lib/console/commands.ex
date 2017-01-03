defmodule Moongate.ConsoleCommands do
  @commands %{
    about: "View version and system information.",
    quit: "Terminate the server gracefully."
  }

  def init_message do
    [
      :reset,
      :inverse,
      "Moongate IEx additions",
      :color240,
      " loaded. Type '",
      :color86,
      'help',
      :color240,
      "' to see a list of commands.",
      :reset,
      "\n"
    ]
    |> Bunt.ANSI.format
    |> IO.puts
  end

  @doc """
  Prints a graphical banner and version information.
  """
  def about do
    Moongate.Core.log(:moongate_banner)
  end

  @doc """
  Prints available Moongate console commands.
  """
  def help do
    Moongate.Core.log({:info, @commands})
  end

  @doc """
  Alias for &quit/0.
  """
  def exit, do: quit

  @doc """
  Requests that the support GenServer terminates Moongate
  gracefully.
  """
  def quit do
    GenServer.cast(:support, :quit)
  end
end